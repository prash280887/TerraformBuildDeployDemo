resource "azurerm_key_vault" "aiutility" {
  name                          = var.key_vault_settings.name
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  purge_protection_enabled      = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_role_assignment" "deployer_is_kv_admin" {
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.aiutility.id
  principal_id         = data.azurerm_client_config.current.object_id
  description          = "Managed by Terraform - Allows the identity used for deployment to perform all actions on the key vault"
}

resource "azurerm_private_endpoint" "key_vault" {
  name                          = "${azurerm_key_vault.aiutility.name}-vault-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_link.id
  custom_network_interface_name = "${azurerm_key_vault.aiutility.name}-vault-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_key_vault.aiutility.name}-vault"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.aiutility.id
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.vaultcore_dns_zone_id]
  }
}

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.aiutility.id
  name                           = "default"
  target_resource_id             = azurerm_key_vault.aiutility.id

  enabled_log {
    category_group = "allLogs"
  }

  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}
