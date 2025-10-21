terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.48.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.7.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
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
