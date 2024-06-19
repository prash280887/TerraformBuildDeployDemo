resource "azurerm_storage_account" "function" {
  name                            = var.storage_account_function_settings.name
  resource_group_name             = data.azurerm_resource_group.aiutility.name
  location                        = data.azurerm_resource_group.aiutility.location
  account_tier                    = var.storage_account_function_settings.tier
  account_replication_type        = var.storage_account_function_settings.replication_type
  account_kind                    = var.storage_account_function_settings.kind
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

resource "azurerm_storage_share" "backend_func" {
  name                 = "aiutility-backend"
  storage_account_name = azurerm_storage_account.function.name
  quota                = 50
  depends_on           = [azurerm_private_endpoint.storage_function_blob, azurerm_private_endpoint.storage_function_file]
}

resource "azurerm_private_endpoint" "storage_function_blob" {
  name                          = "${azurerm_storage_account.function.name}-blob-pe"
  location                      = azurerm_storage_account.function.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_storage_account.function.name}-blob-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.function.name}-blob"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.function.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.blob_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "storage_function_queue" {
  name                          = "${azurerm_storage_account.function.name}-queue-pe"
  location                      = azurerm_storage_account.function.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_storage_account.function.name}-queue-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.function.name}-queue"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.function.id
    subresource_names              = ["queue"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.queue_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "storage_function_table" {
  name                          = "${azurerm_storage_account.function.name}-table-pe"
  location                      = azurerm_storage_account.function.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_storage_account.function.name}-table-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.function.name}-table"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.function.id
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.table_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "storage_function_file" {
  name                          = "${azurerm_storage_account.function.name}-file-pe"
  location                      = azurerm_storage_account.function.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_storage_account.function.name}-file-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.function.name}-file"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.function.id
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.file_dns_zone_id]
  }
}


data "azurerm_monitor_diagnostic_categories" "storage_account_function_diagnostic" {
  resource_id = azurerm_storage_account.function.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_function_diagnostic" {
  name                       = "${azurerm_storage_account.function.name}-diagnostic"
  target_resource_id         = azurerm_storage_account.function.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_function_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_function_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}
