locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  location            = nonsensitive(module.validation.location)
  resource_group_name = nonsensitive(module.validation.resource_group)

  vm_name       = format("%s-%s", local.vcluster_name, random_id.vm_suffix.hex)
  instance_type = var.vcluster.nodeType.spec.properties["instance-type"]

  vnet_id           = var.vcluster.nodeEnvironment.outputs.infrastructure["vnet_id"]
  private_subnet_id = var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result]
  security_group_id = var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"]

  vcluster_node_identity_id = var.vcluster.nodeEnvironment.outputs.infrastructure["vcluster_node_identity_id"]
}
