variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID"
  default     = null
  nullable    = true
}

variable "location" {
  type        = string
  description = "The Azure location"
}

variable "resource_group" {
  type        = string
  description = "The Azure resource group name"
}

provider "azurerm" {
  features {}
  use_cli                   = false
  use_aks_workload_identity = true
  subscription_id           = local.subscription_id
}

locals {
  location        = nonsensitive(split(",", var.location)[0])
  resource_group  = nonsensitive(split(",", var.resource_group)[0])
  subscription_id = try(nonsensitive(split(",", var.subscription_id)[0]), null)
}

resource "null_resource" "validate_location" {
  lifecycle {
    precondition {
      condition     = length(trimspace(local.location)) > 0
      error_message = "location cannot be empty. Please provide a valid Azure location."
    }

    precondition {
      condition     = local.location != "*" && !can(regex("[*?\\[\\]{}]", local.location))
      error_message = "Location cannot be a glob pattern or contain wildcards. Received: '${local.location}'"
    }
  }
}

resource "null_resource" "validate_resource_group" {
  lifecycle {
    precondition {
      condition     = length(trimspace(local.resource_group)) > 0
      error_message = "Resource group cannot be empty. Please provide a valid resource group for your subscription."
    }

    precondition {
      condition     = local.resource_group != "*" && !can(regex("[*?\\[\\]{}]", local.resource_group))
      error_message = "Resource group cannot be a glob pattern or contain wildcards. Received: '${local.resource_group}'"
    }
  }
}

resource "null_resource" "validate_subscription_id" {
  count = local.subscription_id != null ? 1 : 0

  lifecycle {
    precondition {
      condition     = length(trimspace(local.subscription_id)) > 0
      error_message = "Subscription ID cannot be empty. Please provide a valid subscription ID"
    }

    precondition {
      condition     = local.subscription_id != "*" && !can(regex("[*?\\[\\]{}]", local.subscription_id))
      error_message = "Subscription ID cannot be a glob pattern or contain wildcards. Received: '${local.subscription_id}'"
    }
  }
}

# Check if resource group exists
data "azurerm_resource_group" "existing" {
  name = local.resource_group
}

output "location" {
  value = local.location
}

output "resource_group" {
  value = local.resource_group
}

output "subscription_id" {
  value = local.subscription_id
}
