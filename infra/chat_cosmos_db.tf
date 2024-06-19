data "azurerm_cosmosdb_sql_role_definition" "contributor" {
  account_name        = azurerm_cosmosdb_account.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  role_definition_id  = "00000000-0000-0000-0000-000000000002" # Cosmos DB Built-in Data Contributor https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions
}

resource "azurerm_cosmosdb_sql_database" "webchat" {
  name                = "aiutility-web"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  account_name        = azurerm_cosmosdb_account.aiutility.name
}

resource "azurerm_cosmosdb_sql_container" "conversations" {
  name                  = "Conversations"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  account_name          = azurerm_cosmosdb_account.aiutility.name
  database_name         = azurerm_cosmosdb_sql_database.webchat.name
  partition_key_path    = "/userName"
  partition_key_version = 2
  default_ttl           = 60 * 60 * 24 * 365

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
