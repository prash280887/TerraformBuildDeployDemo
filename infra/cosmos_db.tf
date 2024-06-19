resource "azurerm_cosmosdb_account" "aiutility" {
  name                                  = var.cosmosdb_settings.name
  location                              = data.azurerm_resource_group.aiutility.location
  resource_group_name                   = data.azurerm_resource_group.aiutility.name
  offer_type                            = "Standard"
  kind                                  = "GlobalDocumentDB"
  automatic_failover_enabled            = false
  multiple_write_locations_enabled      = false
  is_virtual_network_filter_enabled     = true
  analytical_storage_enabled            = false
  public_network_access_enabled         = false
  network_acl_bypass_for_azure_services = true

  identity {
    type = "SystemAssigned"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = data.azurerm_resource_group.aiutility.location
    failover_priority = 0
    zone_redundant    = false
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
    storage_redundancy  = "Local"
  }
}

resource "azurerm_cosmosdb_sql_database" "backend" {
  name                = "aiutility-backend"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  account_name        = azurerm_cosmosdb_account.aiutility.name
}

resource "azurerm_cosmosdb_sql_container" "quotas" {
  name                  = "quotas"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  account_name          = azurerm_cosmosdb_account.aiutility.name
  database_name         = azurerm_cosmosdb_sql_database.backend.name
  partition_key_path    = "/partitionKey"
  partition_key_version = 2
  default_ttl           = 31536000

  indexing_policy {
    indexing_mode = "consistent"

    excluded_path {
      path = "/*"
    }

    excluded_path {
      path = "/_etag/?"
    }
  }

  conflict_resolution_policy {
    mode                     = "LastWriterWins"
    conflict_resolution_path = "/_ts"
  }
}

resource "azurerm_private_endpoint" "cosmos" {
  name                          = "${azurerm_cosmosdb_account.aiutility.name}-cosmos-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_cosmosdb_account.aiutility.name}-cosmos-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_cosmosdb_account.aiutility.name}-cosmos"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cosmosdb_account.aiutility.id
    subresource_names              = ["sql"]
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.cosmos_dns_zone_id]
  }
}
