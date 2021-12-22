provider "azurerm" {
  features {}
}

locals {
  resource_naming_template = "${var.location}-${var.environment}-%d-${lower(var.intent)}-%s"
}

resource "azurerm_resource_group" "rg" {
  name     = "${format(local.resource_naming_template, 001, "tf")}-rg"
  location = var.location
}

module "network" {
  source                   = "./../../modules/vnetsubnet"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  resource_naming_template = local.resource_naming_template
  environ                  = var.environment
  tags                     = var.tags
}