resource "azurerm_log_analytics_workspace" "aiutility" {
  name                = var.log_analytics_workspace_settings.name
  location            = data.azurerm_resource_group.aiutility.location
  resource_group_name = data.azurerm_resource_group.aiutility.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
