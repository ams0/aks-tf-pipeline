terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.89.0"
    }
  }
  backend "azurerm" {
    use_microsoft_graph = true
  }
}
