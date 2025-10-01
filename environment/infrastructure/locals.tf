locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  location            = nonsensitive(module.validation.location)
  resource_group_name = nonsensitive(module.validation.resource_group)
  resource_group_id   = data.azurerm_resource_group.current.id

  vnet_cidr_block = "10.0.0.0/16"

  # Use 2 AZs if available
  azs = try(
    length(module.regions.regions) > 0 && length(module.regions.regions[0].zones) > 0 ?
    slice(module.regions.regions[0].zones, 0, 2) :
    ["1"],
    ["1"]
  )

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx + length(local.azs))]

  vnet_name = format("%s-%s-vnet", local.vcluster_name, random_id.vnet_suffix.hex)
}
