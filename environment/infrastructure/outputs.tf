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
output "ccm_csi_client_id" {
  value = azurerm_user_assigned_identity.ccm_csi.client_id
}

# For VM
output "ccm_csi_resource_id" {
  value = azurerm_user_assigned_identity.ccm_csi.id
}
