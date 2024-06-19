resource "azurerm_storage_account" "content" {
  name                            = var.storage_account_content_settings.name
  resource_group_name             = data.azurerm_resource_group.aiutility.name
  location                        = data.azurerm_resource_group.aiutility.location
  account_tier                    = var.storage_account_content_settings.tier
  account_replication_type        = var.storage_account_content_settings.replication_type
  account_kind                    = var.storage_account_content_settings.kind
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

resource "azurerm_storage_container" "content" {
  name                  = var.storage_account_content_settings.reports_container_name
  storage_account_name  = azurerm_storage_account.content.name
  container_access_type = "private"

  depends_on = [azurerm_private_endpoint.storage_content_blob]
}

resource "azurerm_private_endpoint" "storage_content_blob" {
  name                          = "${azurerm_storage_account.content.name}-blob-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_link.id
  custom_network_interface_name = "${azurerm_storage_account.content.name}-blob-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_storage_account.content.name}-blob"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.content.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.blob_dns_zone_id]
  }
}

resource "azurerm_storage_container" "legal" {
  storage_account_name  = azurerm_storage_account.content.name
  name                  = "legal"
  container_access_type = "private"

  depends_on = [azurerm_private_endpoint.storage_content_blob]
}

resource "azurerm_storage_blob" "terms_of_use_md" {
  name                   = "tou.md"
  storage_account_name   = azurerm_storage_account.content.name
  storage_container_name = azurerm_storage_container.legal.name
  type                   = "Block"
  source                 = "${path.module}/terms-of-use/tou.md"
}

resource "azurerm_key_vault_secret" "connection_string_secret" {
  name            = var.storage_account_content_settings.blobstorage_connectionstring_secret_name
  value           = azurerm_storage_account.content.primary_blob_connection_string
  key_vault_id    = azurerm_key_vault.aiutility.id
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339
}

data "azurerm_monitor_diagnostic_categories" "storage_account_content_diagnostic" {
  resource_id = azurerm_storage_account.content.id
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_content_diagnostic" {
  name                       = "${azurerm_storage_account.content.name}-diagnostic"
  target_resource_id         = azurerm_storage_account.content.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_content_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.storage_account_content_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}
