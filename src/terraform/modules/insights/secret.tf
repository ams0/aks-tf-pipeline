# resource "azurerm_key_vault_secret" "insights_instrumentation_key" {
#   name         = "insights-instrumentation-key"
#   value        = azurerm_application_insights.insights.instrumentation_key
#   key_vault_id = var.keyvault_id
#   tags         = { secret = true }
# }
