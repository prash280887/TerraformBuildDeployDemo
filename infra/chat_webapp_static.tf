
resource "azurerm_static_web_app" "static_chat" {
  name                = var.chat_settings.frontend_name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  location            = data.azurerm_resource_group.aiutility.location
  sku_tier            = "Standard"
  sku_size            = "Standard"
}

resource "azurerm_private_endpoint" "static_chat" {
  name                          = "${azurerm_static_web_app.static_chat.name}-static-sites-pe"
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  location                      = data.azurerm_resource_group.aiutility.location
  custom_network_interface_name = "${azurerm_static_web_app.static_chat.name}-static-sites-pe-nic"
  subnet_id                     = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "psc-${azurerm_static_web_app.static_chat.name}-static-sites"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_static_web_app.static_chat.id
    subresource_names              = ["staticSites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.static_app_dns_zone_id]
  }
}

output "chat_static_webapp_public_base_url" {
  # value = "https://${azurerm_static_web_app.static_chat.default_host_name}" # TODO: update with public FQDN once available
  value = "https://${var.chat_settings.frontend_public_fqdn}"
}

output "chat_static_webapp_deployment_token" {
  value     = azurerm_static_web_app.static_chat.api_key
  sensitive = true
}
