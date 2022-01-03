
resource "azurerm_log_analytics_workspace" "logs" {
  name                = format(var.resource_naming_template, var.progressive, "logs")
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags

}

resource "azurerm_log_analytics_solution" "container" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}


resource "azurerm_application_insights" "insights" {
  name                = format(var.resource_naming_template, var.progressive, "appi")
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "Node.JS"
  workspace_id        = azurerm_log_analytics_workspace.logs.id

  tags = var.tags
}
