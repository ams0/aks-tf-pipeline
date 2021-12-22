terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.89.0"
    }
  }
  backend "azurerm" {
    use_microsoft_graph  = true
    resource_group_name  = "tfstates"
    storage_account_name = "tfstateblobs"
    container_name       = "tfstates"
    subscription_id      = "12c7e9d6-967e-40c8-8b3e-4659a4ada3ef"
    key                  = "foundation.tfstate"
  }
}
