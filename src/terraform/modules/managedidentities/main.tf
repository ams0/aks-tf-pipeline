data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  resource_group_name = var.resource_group_name
  name                = var.acr_name
}

resource "azurerm_user_assigned_identity" "aks" {
  name                = "${format(var.resource_naming_template, var.progressive, "aks")}-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}

resource "azurerm_user_assigned_identity" "aksnodepool" {
  name                = "${format(var.resource_naming_template, var.progressive, "aksnodepool")}-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}

resource "azurerm_role_assignment" "networkcontrib" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
resource "azurerm_role_assignment" "mi-operator" {
  scope                = azurerm_user_assigned_identity.aksnodepool.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}
resource "azurerm_role_assignment" "acrpull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aksnodepool.principal_id
}
