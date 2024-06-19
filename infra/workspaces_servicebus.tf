resource "azurerm_servicebus_namespace" "this" {
  name                          = var.servicebus_settings.name
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  location                      = data.azurerm_resource_group.aiutility.location
  sku                           = var.servicebus_settings.sku
  capacity                      = var.servicebus_settings.capacity
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  premium_messaging_partitions  = var.servicebus_settings.premium_messaging_partitions
}

resource "azurerm_servicebus_queue" "indexation_requests" {
  namespace_id                         = azurerm_servicebus_namespace.this.id
  name                                 = "indexation-requests"
  dead_lettering_on_message_expiration = true
  default_message_ttl                  = "P14D"
  lock_duration                        = "PT30S"
  max_delivery_count                   = 3
}

# Private Endpoint for the Service Bus Namespace
resource "azurerm_private_endpoint" "servicebus_private_endpoint" {
  name                = "${azurerm_servicebus_namespace.this.name}-pe"
  location            = azurerm_servicebus_namespace.this.location
  resource_group_name = azurerm_servicebus_namespace.this.resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${azurerm_servicebus_namespace.this.name}-psc"
    private_connection_resource_id = azurerm_servicebus_namespace.this.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.servicebus_dns_zone_id]
  }
}

output "servicebus_name" {
  value = azurerm_servicebus_namespace.this.name
}

output "servicebus_queue_name" {
  value = azurerm_servicebus_queue.indexation_requests.name
}
