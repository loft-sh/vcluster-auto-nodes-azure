locals {
  location            = nonsensitive(module.validation.location)
  resource_group_name = nonsensitive(module.validation.resource_group)

  vm_name       = format("%s-%s", var.vcluster.name, random_id.vm_suffix.hex)
  instance_type = nonsensitive(var.vcluster.nodeType.spec.properties["instance-type"])

  vnet_id           = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["vnet_id"])
  private_subnet_id = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["private_subnet_ids"][random_integer.subnet_index.result])
  security_group_id = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["security_group_id"])

  vcluster_node_identity_id = nonsensitive(var.vcluster.nodeEnvironment.outputs.infrastructure["vcluster_node_identity_id"])
}
