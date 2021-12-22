provider "azurerm" {
  features {}
}

locals {
  resource_naming_template = "${var.location}-${var.environment}-%d-${lower(var.intent)}-%s"
}

data "azurerm_resource_group" "rg" {
  name = "${format(local.resource_naming_template, 001, "tf")}-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "${format(var.resource_naming_template, 001, "aks")}-mi"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "aksnodepool" {
  name                = "${format(var.resource_naming_template, 001, "aksnodepool")}-mi"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "spoke" {
  name                = "${format(local.resource_naming_template, 001, "spoke")}-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "spokesubnet" {
  name                 = "subnet-spoke-cluster"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "aksgitops" {
  source                   = "./../../modules/aksgitops"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location

  resource_naming_template = local.resource_naming_template

  sp_client_secret = var.sp_client_secret
  sp_tenantid      = var.sp_tenantid
  sp_clientid      = var.sp_clientid

  #AAD
  tenant_id              = var.tenant_id
  admin_group_object_ids = var.admin_group_object_ids

  #MIs
  ##cluster identity
  cluster_identity_type     = "UserAssigned"
  user_assigned_identity_id = data.azurerm_user_assigned_identity.aks.id

  ##nodepool identity
  # client_id                         = data.azurerm_user_assigned_identity.aksnodepool.client_id
  # object_id                         = data.azurerm_user_assigned_identity.aksnodepool.principal_id
  # kubelet_user_assigned_identity_id = data.azurerm_user_assigned_identity.aksnodepool.id

  #gitops
  enable_gitops       = var.enable_gitops
  git_repo            = var.git_repo
  git_branch          = var.git_branch
  ssh_priv_key_base64 = var.ssh_priv_key_base64

  #network
  vnet_subnet_id = data.azurerm_subnet.spoke.id

  tags           = var.tags
}

