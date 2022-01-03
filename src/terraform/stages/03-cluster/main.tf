provider "azurerm" {
  features {}
}

locals {
  resource_naming_template = "${var.location}-${var.environment}-%d-${lower(var.intent)}-%s"
}

data "azurerm_resource_group" "rg" {
  name = "${format(local.resource_naming_template, var.progressive, "tf")}-rg"
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "${format(local.resource_naming_template, var.progressive, "aks")}-mi"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_user_assigned_identity" "aksnodepool" {
  name                = "${format(local.resource_naming_template, var.progressive, "aksnodepool")}-mi"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_virtual_network" "spoke" {
  name                = "${format(local.resource_naming_template, var.progressive, "spokes")}-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "spokesubnet" {
  name                 = "subnet-spoke-cluster"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_log_analytics_workspace" "appi" {
  name                = format(local.resource_naming_template, var.progressive, "appi")
  resource_group_name = data.azurerm_resource_group.rg.name
}
module "aksgitops" {
  source              = "./../../modules/aksgitops"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  progressive         = var.progressive

  resource_naming_template = local.resource_naming_template

  #AAD
  tenant_id              = var.tenant_id
  admin_group_object_ids = var.admin_group_object_ids

  nodepools = var.nodepools
  #MIs
  ##cluster identity
  cluster_identity_type     = "UserAssigned"
  user_assigned_identity_id = data.azurerm_user_assigned_identity.aks.id

  ##nodepool identity
  nodepool_mi_client_id                         = data.azurerm_user_assigned_identity.aksnodepool.client_id
  nodepool_mi_object_id                         = data.azurerm_user_assigned_identity.aksnodepool.principal_id
  nodepool_mi_kubelet_user_assigned_identity_id = data.azurerm_user_assigned_identity.aksnodepool.id

  #gitops
  enable_gitops       = true
  git_repo            = var.git_repo
  git_branch          = var.git_branch
  ssh_priv_key_base64 = var.ssh_priv_key_base64

  #network
  vnet_subnet_id = data.azurerm_subnet.spokesubnet.id

  #monitoring
  addon_oms_agent_enabled    = true
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.appi.id

  tags = var.tags
}
