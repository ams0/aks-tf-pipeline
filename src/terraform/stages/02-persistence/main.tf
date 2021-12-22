provider "azurerm" {
  features {}
}

locals {
  resource_naming_template = "${var.location}-${var.environment}-%d-${lower(var.intent)}-%s"
}

data "azurerm_resource_group" "rg" {
  name = "${format(local.resource_naming_template, 001, "tf")}-rg"
}

data "azurerm_virtual_network" "hub" {
    name = "${format(var.resource_naming_template, 001, "hub")}-vnet"
    resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "hubprivate" {
  name                 = "subnet-hub-private"
  virtual_network_name = data.azurerm_virtual_network.hub.name
    resource_group_name = data.azurerm_resource_group.rg.name
}
module "acr" {
  source                   = "./../../modules/acr"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.location
  resource_naming_template = local.resource_naming_template
  subnet_id                = data.azurerm_subnet.hubprivate
  private_vnet_id          = data.azurerm_virtual_network.hub.id
  tags                     = var.tags
}

# module "keyvault" {
#   source                   = "./../../modules/cosmosdb"
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   resource_naming_template = local.resource_naming_template
#   subnet_id                = var.subnet_id
#   private_vnet_id          = var.private_vnet_id
#   tags                     = var.tags
# }
# module "managedidentities" {
#   source = "./../../modules/managedidentities"
# }
# module "insights" {
#   source       = "./../../modules/insights"
#   resource_group_name      = var.resource_group_name
#   location                 = var.location
#   resource_naming_template = local.resource_naming_template
#   tags                     = var.tags
#   keyvault_id              = module.keyvault.keyvault_id
# }