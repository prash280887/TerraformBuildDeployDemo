resource "azurerm_container_registry" "aiutility" {
  name                          = var.container_registry_settings.name
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  location                      = data.azurerm_resource_group.aiutility.location
  sku                           = "Premium" # Premium required for Private Link
  public_network_access_enabled = false
  anonymous_pull_enabled        = false
  admin_enabled                 = true # Required for test deployment
  data_endpoint_enabled         = true
}

# Private Endpoint for the Container Registry
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${azurerm_container_registry.aiutility.name}-pe"
  location            = azurerm_container_registry.aiutility.location
  resource_group_name = azurerm_container_registry.aiutility.resource_group_name
  subnet_id           = data.azurerm_subnet.private_endpoint.id

  private_service_connection {
    name                           = "${azurerm_container_registry.aiutility.name}-psc"
    private_connection_resource_id = azurerm_container_registry.aiutility.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.acr_dns_zone_id]
  }
}

resource "azurerm_role_assignment" "deployer_can_push_images" {
  scope                = azurerm_container_registry.aiutility.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
  description          = "Managed by Terraform - Allow the deployment identity to push images to the container registry"
}

output "container_registry_name" {
  value = azurerm_container_registry.aiutility.name
}
