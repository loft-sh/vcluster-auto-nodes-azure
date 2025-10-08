locals {
  vcluster_name       = nonsensitive(var.vcluster.instance.metadata.name)
  location            = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["location"])
  resource_group_name = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["resource_group_name"])
  subscription_id     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["subscription_id"])
  ccm_csi_client_id   = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["ccm_csi_client_id"])
  security_group_name = format("%s-workers-nsg", local.vcluster_name)
  node_provider_name  = nonsensitive(var.vcluster.nodeProvider.metadata.name)
}
