provider "azurerm" {
  features {}
}

locals {
  resource_naming_template = "${var.location}-${var.environment}-%d-${lower(var.intent)}-%s"
}

data "azurerm_resource_group" "rg" {
  name = "${format(local.resource_naming_template, var.progressive, "tf")}-rg"
}

data "azurerm_virtual_network" "spoke" {
  name                = "${format(local.resource_naming_template, var.progressive, "spokes")}-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "cluster" {
  name                 = "subnet-spoke-cluster"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "acr" {
  source              = "./../../modules/acr"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  progressive         = var.progressive

  resource_naming_template = local.resource_naming_template
  subnet_id                = data.azurerm_subnet.cluster.id
  private_vnet_id          = data.azurerm_virtual_network.spoke.id
  tags                     = var.tags
}

module "keyvault" {

  #checkov:skip=CKV_AZURE_109:Ensure that key vault allows firewall rules settings
  #checkov:skip=CKV_AZURE_110:Ensure that key vault enables purge protection
  #checkov:skip=CKV_AZURE_114:Ensure that key vault secrets have "content_type" set
  #checkov:skip=CKV_AZURE_41:Ensure that the expiration date is set on all secrets
  #checkov:skip=CKV_AZURE_42:Ensure the key vault is recoverable


  source              = "./../../modules/keyvault"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  progressive         = var.progressive

  resource_naming_template = local.resource_naming_template
  subnet_id                = data.azurerm_subnet.cluster.id
  private_vnet_id          = data.azurerm_virtual_network.spoke.id
  tags                     = var.tags
}

module "managedidentities" {
  source              = "./../../modules/managedidentities"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  progressive         = var.progressive

  resource_naming_template = local.resource_naming_template

  acr_name = module.acr.acr_name
  tags     = var.tags

  depends_on = [
    module.acr
  ]

}


module "insights" {
  source              = "./../../modules/insights"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  progressive         = var.progressive

  resource_naming_template = local.resource_naming_template
  tags                     = var.tags
  keyvault_id              = module.keyvault.keyvault_id

  depends_on = [
    module.keyvault
  ]
}
