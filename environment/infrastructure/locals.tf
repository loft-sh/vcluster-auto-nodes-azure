locals {
  location            = nonsensitive(module.validation.location)
  resource_group_name = nonsensitive(module.validation.resource_group)
  resource_group_id   = data.azurerm_resource_group.current.id
  location_rgroup_key = format("%s-%s", local.location, local.resource_group_name)

  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  # A random_id resource cannot be used here because of how the VNet module applies resources.
  # The module needs resource names to be known in advance.
  random_id = substr(md5(format("%s%s", local.vcluster_namespace, local.vcluster_name)), 0, 8)

  # The name of the property is set to 'vpc-cidr' to keep the same naming accross different quick start templates
  vnet_cidr_block = try(var.vcluster.properties["vcluster.com/vpc-cidr"], "10.5.0.0/16")

  # Use 2 AZs if available
  azs = try(
    length(module.regions.regions) > 0 && length(module.regions.regions[0].zones) > 0 ?
    slice(module.regions.regions[0].zones, 0, 2) :
    ["1"],
    ["1"]
  )

  public_subnets  = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx)]
  private_subnets = [for idx, az in local.azs : cidrsubnet(local.vnet_cidr_block, 8, idx + length(local.azs))]

  ccm_enabled = try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true)
  csi_enabled = try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true)
}
