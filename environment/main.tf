resource "random_id" "vnet_suffix" {
  byte_length = 4
}

module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.7"

  region_filter          = [local.location]
  has_availability_zones = true
}

module "nat_gateway" {
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "~> 0.2"

  name                = format("%s-nat-gateway", local.vcluster_name)
  location            = local.location
  resource_group_name = local.resource_group_name

  # Configure public IPs for NAT Gateway
  public_ips = {
    pip1 = {
      name = format("%s-nat-pip", local.vcluster_name)
    }
  }

  public_ip_configuration = {
    allocation_method = "Static"
    sku               = "Standard"
    zones             = local.azs
  }

  tags = {
    "Name"               = format("%s-nat-gateway", local.vcluster_name)
    "vcluster:name"      = local.vcluster_name
    "vcluster:namespace" = local.vcluster_namespace
  }
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.10"

  name                = local.vnet_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.vnet_cidr_block]

  subnets = merge(
    # Public subnets
    {
      for idx, az in local.azs : format("%s-public-%s", local.vcluster_name, az) => {
        name             = format("%s-public-%s", local.vcluster_name, az)
        address_prefixes = [local.public_subnets[idx]]
      }
    },
    # Private subnets
    {
      for idx, az in local.azs : format("%s-private-%s", local.vcluster_name, az) => {
        name             = format("%s-private-%s", local.vcluster_name, az)
        address_prefixes = [local.private_subnets[idx]]
        network_security_group = {
          id = azurerm_network_security_group.workers.id
        }
        nat_gateway = {
          id = module.nat_gateway.resource.id
        }
      }
    }
  )

  tags = {
    "Name"               = local.vnet_name
    "vcluster:name"      = local.vcluster_name
    "vcluster:namespace" = local.vcluster_namespace
  }

  depends_on = [azurerm_network_security_group.workers, module.nat_gateway]
}

