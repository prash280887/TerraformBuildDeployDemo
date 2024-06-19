resource "azurerm_search_service" "workspaces" {
  name                = var.search_settings.name
  location            = data.azurerm_resource_group.aiutility.location
  resource_group_name = data.azurerm_resource_group.aiutility.name


  identity {
    type = "SystemAssigned"
  }

  sku                          = var.search_settings.sku_name
  local_authentication_enabled = false
}

resource "azurerm_private_endpoint" "search_workspaces" {
  name                          = "${azurerm_search_service.workspaces.name}-search-pe"
  location                      = azurerm_search_service.workspaces.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_search_service.workspaces.name}-search-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_search_service.workspaces.name}-search"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_search_service.workspaces.id
    subresource_names              = ["searchService"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.search_dns_zone_id]
  }
}
output "workspaces_search_endpoint" {
  value = "https://${azurerm_search_service.workspaces.name}.search.windows.net"
}
