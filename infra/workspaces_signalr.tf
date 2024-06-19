resource "azurerm_signalr_service" "this" {
  name                          = var.signalr_settings.name
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  location                      = data.azurerm_resource_group.aiutility.location
  service_mode                  = "Serverless"
  connectivity_logs_enabled     = true
  http_request_logs_enabled     = true
  messaging_logs_enabled        = true
  public_network_access_enabled = false

  live_trace {
    enabled                   = true
    connectivity_logs_enabled = true
    http_request_logs_enabled = true
    messaging_logs_enabled    = true
  }

  cors {
    allowed_origins = var.workspace_api_settings.allowed_origins
  }

  sku {
    name     = var.signalr_settings.sku_name
    capacity = var.signalr_settings.sku_capacity
  }
}
resource "azurerm_private_endpoint" "signalr_private_endpoint" {
  name                = "${azurerm_signalr_service.this.name}-pe"
  location            = azurerm_signalr_service.this.location
  resource_group_name = azurerm_signalr_service.this.resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${azurerm_signalr_service.this.name}-psc"
    private_connection_resource_id = azurerm_signalr_service.this.id
    is_manual_connection           = false
    subresource_names              = ["signalr"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.signalr_dns_zone_id]
  }
}
