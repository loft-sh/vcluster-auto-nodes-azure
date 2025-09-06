output "private_subnet_ids" {
  description = "A list of private subnet ids"
  value = [
    for az in local.azs : module.vnet.subnets[format("%s-private-%s", local.vcluster_name, az)].resource_id
  ]
}

output "public_subnet_ids" {
  description = "A list of public subnet ids"
  value = [
    for az in local.azs : module.vnet.subnets[format("%s-public-%s", local.vcluster_name, az)].resource_id
  ]
}

output "security_group_id" {
  description = "Security group id to attach to worker nodes"
  value       = azurerm_network_security_group.workers.id
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.vnet.resource_id
}
