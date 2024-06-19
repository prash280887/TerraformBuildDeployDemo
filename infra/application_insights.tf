resource "azurerm_application_insights" "aiutility" {
  name                       = var.app_insights_settings.name
  location                   = data.azurerm_resource_group.aiutility.location
  resource_group_name        = data.azurerm_resource_group.aiutility.name
  workspace_id               = azurerm_log_analytics_workspace.aiutility.id
  application_type           = "web"
  retention_in_days          = 90
  internet_ingestion_enabled = true
  internet_query_enabled     = true
}
