resource "azurerm_storage_account" "workspaces_docs" {
  name                            = var.storage_account_workspaces_settings.name
  location                        = data.azurerm_resource_group.aiutility.location
  resource_group_name             = data.azurerm_resource_group.aiutility.name
  account_tier                    = var.storage_account_workspaces_settings.tier
  account_replication_type        = var.storage_account_workspaces_settings.replication_type
  account_kind                    = var.storage_account_workspaces_settings.kind
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

  blob_properties {
    delete_retention_policy {
      days = 365
    }
    container_delete_retention_policy {
      days = 365
    }
    change_feed_enabled = true
  }
}

# Private Endpoint for Blob service
resource "azurerm_private_endpoint" "storage_account_blob_pe" {
  name                          = "${azurerm_storage_account.workspaces_docs.name}-blob-pe"
  location                      = azurerm_storage_account.workspaces_docs.location
  resource_group_name           = azurerm_storage_account.workspaces_docs.resource_group_name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "nic-pe-${azurerm_storage_account.workspaces_docs.name}-blob"

  private_service_connection {
    name                           = "${azurerm_storage_account.workspaces_docs.name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.workspaces_docs.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.blob_dns_zone_id]
  }
}

# Private Endpoint for Queue service
resource "azurerm_private_endpoint" "storage_account_queue_pe" {
  name                          = "${azurerm_storage_account.workspaces_docs.name}-queue-pe"
  location                      = azurerm_storage_account.workspaces_docs.location
  resource_group_name           = azurerm_storage_account.workspaces_docs.resource_group_name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "nic-pe-${azurerm_storage_account.workspaces_docs.name}-queue"

  private_service_connection {
    name                           = "${azurerm_storage_account.workspaces_docs.name}-queue-psc"
    private_connection_resource_id = azurerm_storage_account.workspaces_docs.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.queue_dns_zone_id]
  }
}

# Private Endpoint for Table service
resource "azurerm_private_endpoint" "storage_account_table_pe" {
  name                          = "${azurerm_storage_account.workspaces_docs.name}-table-pe"
  location                      = azurerm_storage_account.workspaces_docs.location
  resource_group_name           = azurerm_storage_account.workspaces_docs.resource_group_name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "nic-pe-${azurerm_storage_account.workspaces_docs.name}-table"

  private_service_connection {
    name                           = "${azurerm_storage_account.workspaces_docs.name}-table-psc"
    private_connection_resource_id = azurerm_storage_account.workspaces_docs.id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.table_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "storage_account_file_pe" {
  name                          = "${azurerm_storage_account.workspaces_docs.name}-file-pe"
  location                      = azurerm_storage_account.workspaces_docs.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_storage_account.workspaces_docs.name}-file-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.workspaces_docs.name}-file"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.workspaces_docs.id
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.file_dns_zone_id]
  }
}

data "azurerm_monitor_diagnostic_categories" "storage_account_workspaces_docs_diagnostic" {
  resource_id = azurerm_storage_account.workspaces_docs.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_workspaces_docs_diagnostic" {
  name                       = "${var.storage_account_workspaces_settings.name}-diagnostic"
  target_resource_id         = azurerm_storage_account.workspaces_docs.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_workspaces_docs_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_workspaces_docs_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}
