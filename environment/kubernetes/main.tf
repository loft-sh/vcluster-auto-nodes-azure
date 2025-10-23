##############
# Cloud Config
##############

module "kubernetes_apply_config" {
  for_each = local.ccm_enabled || local.csi_enabled ? { "enabled" = true } : {}

  source        = "./apply"
  manifest_file = "${path.module}/manifests/cloud-config.yaml.tftpl"

  template_vars = {
    vcluster_name           = local.vcluster_name
    location                = local.location
    resource_group_name     = local.resource_group_name
    subscription_id         = local.subscription_id
    security_group_name     = local.security_group_name
    vcluster_node_client_id = local.vcluster_node_client_id
    node_provider_name      = local.node_provider_name
    suffix                  = local.suffix
  }

  computed_fields = ["stringData", "data"]
}

##########
# CCM
#########

module "kubernetes_apply_ccm" {
  for_each = local.ccm_enabled ? { "enabled" = true } : {}

  source        = "./apply"
  manifest_file = "${path.module}/manifests/ccm.yaml.tftpl"

  template_vars = {
    vcluster_name      = local.vcluster_name
    node_provider_name = local.node_provider_name
    controllers        = local.ccm_lb_enabled ? "*,-cloud-node" : "*,-cloud-node,-service"
    suffix             = local.suffix
  }

  depends_on = [module.kubernetes_apply_config]
}

##########
# CNM
#########

module "kubernetes_apply_cnm" {
  for_each = local.ccm_enabled ? { "enabled" = true } : {}

  source        = "./apply"
  manifest_file = "${path.module}/manifests/cnm.yaml.tftpl"

  template_vars = {
    node_provider_name = local.node_provider_name
    suffix             = local.suffix
  }
}

##########
# CSI
#########

module "kubernetes_apply_csi" {
  source = "./apply"

  for_each = local.csi_enabled ? toset([
    "${path.module}/manifests/csi-disk-controller.yaml.tftpl",
    "${path.module}/manifests/csi-disk-node.yaml.tftpl",
    "${path.module}/manifests/csi-snapshot-crd.yaml.tftpl",
    "${path.module}/manifests/csi-snapshot-controller.yaml.tftpl"
  ]) : toset([])

  manifest_file = each.value

  template_vars = {
    node_provider_name = local.node_provider_name
    suffix             = local.suffix
  }

  depends_on = [module.kubernetes_apply_config]
}
