resource "azurerm_network_security_group" "workers" {
  name                = format("%s-workers-nsg", local.vcluster_name)
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "allow-intra-vnet"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = local.vnet_cidr_block
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-kubelet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = local.vnet_cidr_block
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-nodeport-range"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = local.vnet_cidr_block
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh-from-vnet"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = local.vnet_cidr_block
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-all-outbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
