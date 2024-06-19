resource "azurerm_storage_account" "config" {
  name                            = var.storage_account_config_settings.name
  resource_group_name             = data.azurerm_resource_group.aiutility.name
  location                        = data.azurerm_resource_group.aiutility.location
  account_tier                    = var.storage_account_config_settings.tier
  account_replication_type        = var.storage_account_config_settings.replication_type
  account_kind                    = var.storage_account_config_settings.kind
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

resource "azurerm_storage_container" "config" {
  name                  = var.storage_account_config_settings.config_container_name
  storage_account_name  = azurerm_storage_account.config.name
  container_access_type = "private"

  depends_on = [azurerm_private_endpoint.storage_config_blob]
}

resource "azurerm_role_assignment" "devops_blob_contributor" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.config.id
  principal_id         = data.azurerm_client_config.current.object_id
  description          = "Managed by Terraform - Allows the identity used for deployment to manage blob data"
}

resource "azurerm_private_endpoint" "storage_config_blob" {
  name                          = "${azurerm_storage_account.config.name}-blob-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_link.id
  custom_network_interface_name = "${azurerm_storage_account.config.name}-blob-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.config.name}-blob"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.config.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.blob_dns_zone_id]
  }
}

data "azurerm_monitor_diagnostic_categories" "storage_account_config_diagnostic" {
  resource_id = azurerm_storage_account.config.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_config_diagnostic" {
  name                       = "${var.storage_account_config_settings.name}-diagnostic"
  target_resource_id         = azurerm_storage_account.config.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_config_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_config_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}
