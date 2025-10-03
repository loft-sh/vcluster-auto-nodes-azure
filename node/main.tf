module "validation" {
  source = "./validation"

  location        = var.vcluster.properties["location"]
  resource_group  = var.vcluster.properties["resource-group"]
  subscription_id = try(var.vcluster.properties["subscription-id"], null)
}

resource "random_id" "vm_suffix" {
  byte_length = 4
}

resource "random_integer" "subnet_index" {
  min = 0
  max = length(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"]) - 1
}

resource "azurerm_network_interface" "private_vm" {
  name                = "${local.vm_name}-nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "private_vm" {
  network_interface_id      = azurerm_network_interface.private_vm.id
  network_security_group_id = local.security_group_id
}

resource "tls_private_key" "vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_linux_virtual_machine" "private_vm" {
  name                = local.vm_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.instance_type
  admin_username      = "azureuser"

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.vm_ssh.public_key_openssh
  }

  network_interface_ids = [
    azurerm_network_interface.private_vm.id,
  ]

  user_data = base64encode(var.vcluster.userData)

  identity {
    type         = "UserAssigned"
    identity_ids = [local.ccm_csi_resource_id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 100
  }

  # Ubuntu 22.04 LTS
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    "Name"               = local.vm_name
    "vcluster:name"      = local.vcluster_name
    "vcluster:namespace" = local.vcluster_namespace
  }
}
