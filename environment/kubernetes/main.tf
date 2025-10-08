##############
# Cloud Config
##############

module "kubernetes_apply_config" {
  source        = "./apply"
  manifest_file = "${path.module}/manifests/cloud-config.yaml.tftpl"

  template_vars = {
    vcluster_name       = local.vcluster_name
    location            = local.location
    resource_group_name = local.resource_group_name
    subscription_id     = local.subscription_id
    security_group_name = local.security_group_name
    ccm_csi_client_id   = local.ccm_csi_client_id
    node_provider_name  = local.node_provider_name
  }

  computed_fields = ["stringData", "data"]
}

##########
# CCM
#########

module "kubernetes_apply_ccm" {
  source        = "./apply"
  manifest_file = "${path.module}/manifests/ccm.yaml.tftpl"

  template_vars = {
    vcluster_name = local.vcluster_name
  }

  depends_on = [module.kubernetes_apply_config]
}

##########
# CNM
#########

module "kubernetes_apply_cnm" {
  source        = "./apply"
  manifest_file = "${path.module}/manifests/cnm.yaml.tftpl"
}

##########
# CSI
#########

module "kubernetes_apply_csi" {
  source = "./apply"

  for_each = toset([
    "${path.module}/manifests/csi-disk-controller.yaml.tftpl",
    "${path.module}/manifests/csi-disk-node.yaml.tftpl",
    "${path.module}/manifests/csi-snapshot-crd.yaml.tftpl",
    "${path.module}/manifests/csi-snapshot-controller.yaml.tftpl"
  ])

  manifest_file = each.value

  depends_on = [module.kubernetes_apply_config]
}
