
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${format(var.resource_naming_template, 001, "aks")}-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}

resource "azurerm_user_assigned_identity" "aksnodepool" {
  name                = "${format(var.resource_naming_template, 001, "aksnodepool")}-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

}
