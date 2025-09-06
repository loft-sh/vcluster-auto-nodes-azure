locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  location            = nonsensitive(split(",", var.vcluster.requirements["location"])[0])
  resource_group_name = var.vcluster.requirements["resource-group"]

  vnet_cidr_block = "10.0.0.0/16"

  azs = length(module.regions.regions) > 0 && length(module.regions.regions[0].zones) > 0 ? module.regions.regions[0].zones : ["1"]

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx + length(local.azs))]

  vnet_name = format("%s-%s-vnet", local.vcluster_name, random_id.vnet_suffix.hex)
}
