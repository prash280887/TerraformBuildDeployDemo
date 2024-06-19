resource "azurerm_api_management_named_value" "aiutility_backend_apikey" {
  name                = "aiutility-backend-apikey"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "aiutility-backend-apikey"
  value_from_key_vault {
    secret_id = azurerm_key_vault_secret.function.id
  }
  secret = true

  depends_on = [azurerm_role_assignment.apim_is_secrets_user_on_kv]
}

resource "azurerm_api_management_named_value" "aiutility_backend_endpoint" {
  name                = "aiutility-backend-endpoint"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "aiutility-backend-endpoint"
  value               = "https://${azurerm_linux_function_app.backend.default_hostname}"
}

resource "azurerm_api_management_named_value" "aiutility_mapping_blob_url" {
  name                = "aiutility-mapping-blob-url"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "aiutility-mapping-blob-url"
  value               = "${azurerm_storage_account.config.primary_blob_endpoint}${azurerm_storage_container.config.name}/${azurerm_storage_blob.mapping_config.name}"
}

resource "azurerm_storage_blob" "mapping_config" {
  name                   = "mapping.json"
  storage_account_name   = azurerm_storage_account.config.name
  storage_container_name = azurerm_storage_container.config.name
  type                   = "Block"
  content_type           = "application/json"
  source_content         = jsonencode(local.aiutility_mapping)
  depends_on             = [azurerm_role_assignment.devops_blob_contributor]
}
