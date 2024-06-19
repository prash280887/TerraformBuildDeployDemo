resource "azurerm_public_ip" "apim" {
  name                = var.apim_settings.public_ip_name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  location            = data.azurerm_resource_group.aiutility.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = var.apim_settings.name
}

resource "azurerm_api_management" "aiutility" {
  name                 = var.apim_settings.name
  location             = data.azurerm_resource_group.aiutility.location
  resource_group_name  = data.azurerm_resource_group.aiutility.name
  publisher_name       = var.apim_settings.publisher_name
  publisher_email      = var.apim_settings.publisher_email
  sku_name             = var.apim_settings.sku
  virtual_network_type = "Internal"
  public_ip_address_id = azurerm_public_ip.apim.id

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = data.azurerm_subnet.apim.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.apim_to_subnet]
}

resource "azurerm_role_assignment" "apim_is_secrets_user_on_kv" {
  scope                = azurerm_key_vault.aiutility.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_api_management.aiutility.identity[0].principal_id
  description          = "Managed by Terraform - Allows APIM to retrieve secrets from the key vault"
}

resource "azurerm_role_assignment" "apim_is_openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_api_management.aiutility.identity[0].principal_id
  description          = "Managed by Terraform - Allows APIM to access OpenAI and forward requests to it"
}

resource "azurerm_role_assignment" "apim_is_openai_secondary_user" {
  scope                = azurerm_cognitive_account.openai_secondary.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_api_management.aiutility.identity[0].principal_id
  description          = "Managed by Terraform - Allows APIM to access OpenAI and forward requests to it"
}

resource "azurerm_role_assignment" "apim_config_blob_reader" {
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.config.id
  principal_id         = azurerm_api_management.aiutility.identity[0].principal_id
  description          = "Managed by Terraform - Allow apim to read config from blob storage"
}
