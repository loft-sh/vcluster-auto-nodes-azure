locals {
  vcluster_name      = nonsensitive(var.vcluster.instance.metadata.name)
  vcluster_namespace = nonsensitive(var.vcluster.instance.metadata.namespace)

  location            = nonsensitive(split(",", var.vcluster.requirements["location"])[0])
  resource_group_name = var.vcluster.requirements["resource-group"]

  vm_name           = format("%s-worker-node-%s", local.vcluster_name, random_id.vm_suffix.hex)
  private_subnet_id = var.vcluster.nodeEnvironment.outputs["private_subnet_ids"][random_integer.subnet_index.result]
  instance_type     = var.vcluster.nodeType.spec.properties["instance-type"]
  security_group_id = var.vcluster.nodeEnvironment.outputs["security_group_id"]
}
