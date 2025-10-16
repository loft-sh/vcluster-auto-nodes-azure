locals {
  location            = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["location"])
  resource_group_name = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["resource_group_name"])
  subscription_id     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["subscription_id"])

  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  node_provider_name = nonsensitive(var.vcluster.nodeProvider.metadata.name)

  security_group_name     = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_name"])
  vcluster_node_client_id = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["vcluster_node_client_id"])

  ccm_enabled    = try(tobool(var.vcluster.properties["vcluster.com/ccm-enabled"]), true)
  ccm_lb_enabled = try(tobool(var.vcluster.properties["vcluster.com/ccm-lb-enabled"]), true)
  csi_enabled    = try(tobool(var.vcluster.properties["vcluster.com/csi-enabled"]), true)
}
