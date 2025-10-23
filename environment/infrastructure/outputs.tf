output "private_subnet_ids" {
  description = "A list of private subnet ids"
  value = [
    for az in local.azs : module.subnet_private[format("vcluster-private-%s-%s", local.random_id, az)].resource_id
  ]
}

output "public_subnet_ids" {
  description = "A list of public subnet ids"
  value = [
    for az in local.azs : module.subnet_public[format("vcluster-public-%s-%s", local.random_id, az)].resource_id
  ]
}

output "security_group_id" {
  description = "Security group id to attach to worker nodes"
  value       = azurerm_network_security_group.workers.id
}

output "security_group_name" {
  description = "Security group name for CCM to expose LB"
  value       = azurerm_network_security_group.workers.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = module.vnet[local.location_rgroup_key].resource_id
}

output "resource_group_name" {
  value = local.resource_group_name
}

output "location" {
  value = local.location
}

output "subscription_id" {
  value = split("/", data.azurerm_resource_group.current.id)[2]
}

# For IMDS token requests
output "vcluster_node_client_id" {
  value = azurerm_user_assigned_identity.vcluster_node.client_id
}

# For VM
output "vcluster_node_identity_id" {
  value = azurerm_user_assigned_identity.vcluster_node.id
}
