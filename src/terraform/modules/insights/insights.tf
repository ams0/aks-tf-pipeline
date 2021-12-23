resource "azurerm_application_insights" "insights" {
  name                = format(var.resource_naming_template, 001, "appi")
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "Node.JS"
  tags                = var.tags
}
