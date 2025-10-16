terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.48"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli                   = false
  use_aks_workload_identity = true
  subscription_id           = module.validation.subscription_id
}

provider "azapi" {
  use_cli                   = false
  use_aks_workload_identity = true
  subscription_id           = module.validation.subscription_id
}
