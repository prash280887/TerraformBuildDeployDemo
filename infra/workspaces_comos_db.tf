resource "azurerm_cosmosdb_sql_database" "workspaces" {
  name                = "aiutility-workspaces"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  account_name        = azurerm_cosmosdb_account.aiutility.name
}

resource "azurerm_cosmosdb_sql_container" "workspaces" {
  name                  = "workspaces"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  account_name          = azurerm_cosmosdb_account.aiutility.name
  database_name         = azurerm_cosmosdb_sql_database.workspaces.name
  partition_key_path    = "/ownerUserId"
  partition_key_version = 2
  default_ttl           = 90 * 24 * 60 * 60

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
output "workspaces_cosmos_container_name" {
  value = azurerm_cosmosdb_sql_container.workspaces.name
}
