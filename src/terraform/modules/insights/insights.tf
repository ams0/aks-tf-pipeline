resource "azurerm_application_insights" "insights" {
  name                = format(var.resource_naming_template, 001, "appi")
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "Node.JS"
  tags                = var.tags
}

resource "azurerm_key_vault_secret" "insights_instrumentation_key" {
  name         = "insights-instrumentation-key"
  value        = azurerm_application_insights.insights.instrumentation_key
  key_vault_id = var.keyvault_id
  tags         = { secret = true }
}
