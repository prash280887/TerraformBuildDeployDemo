resource "azurerm_service_plan" "aiutility" {
  name                   = var.app_service_plan_settings.name
  resource_group_name    = data.azurerm_resource_group.aiutility.name
  location               = data.azurerm_resource_group.aiutility.location
  os_type                = "Linux"
  sku_name               = var.app_service_plan_settings.sku_name
  zone_balancing_enabled = false
}
