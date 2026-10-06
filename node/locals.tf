locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  infrastructure = var.vcluster.networkEnvironment.outputs.infrastructure

  location            = nonsensitive(module.validation.location)
  resource_group_name = nonsensitive(module.validation.resource_group)

  vm_name       = format("%s-%s", local.vcluster_name, random_id.vm_suffix.hex)
  instance_type = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])

  vnet_id           = nonsensitive(local.infrastructure["vnet_id"])
  private_subnet_id = nonsensitive(local.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  security_group_id = nonsensitive(local.infrastructure["security_group_id"])

  vcluster_node_identity_id = nonsensitive(local.infrastructure["vcluster_node_identity_id"])
}
