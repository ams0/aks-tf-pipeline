
resource "azurerm_user_assigned_identity" "aks" {
  name                = replace(format(var.resource_naming_template, 001, "aks"), "-", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}

resource "azurerm_user_assigned_identity" "aksnodepool" {
  name                = replace(format(var.resource_naming_template, 001, "aksnodepool"), "-", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}
