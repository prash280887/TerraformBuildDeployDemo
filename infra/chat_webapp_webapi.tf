# resource "azurerm_key_vault_secret" "webapi_chat_client_secret" {
#   content_type = "text/plain"
#   name         = "webapi-chat-client-secret"
#   value        = var.chat_web_api_client_secret
#   key_vault_id = azurerm_key_vault.aiutility.id
# }
data "azurerm_key_vault_secret" "webapi_chat_client_secret" {
  name         = "AIUty-GuardianWebAPI"
  key_vault_id = azurerm_key_vault.aiutility.id
}

resource "azurerm_linux_web_app" "webapi_chat" {
  name                                     = var.chat_settings.webapi_webapp_name
  resource_group_name                      = data.azurerm_resource_group.aiutility.name
  location                                 = data.azurerm_resource_group.aiutility.location
  service_plan_id                          = azurerm_service_plan.aiutility.id
  virtual_network_subnet_id                = data.azurerm_subnet.app_service.id
  public_network_access_enabled            = false
  https_only                               = true
  ftp_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    cors {
      allowed_origins     = ["https://${var.chat_settings.frontend_public_fqdn}"]
      support_credentials = true
    }
    application_stack {
      dotnet_version = "8.0"
    }
    always_on               = true
    ftps_state              = "Disabled"
    http2_enabled           = true
    websockets_enabled      = false
    health_check_path       = "/healthz"
    minimum_tls_version     = "1.2"
    scm_minimum_tls_version = "1.2"
  }

  app_settings = {
    "WEBSITE_DNS_SERVER"                         = var.webapp_dns.primary
    "WEBSITE_DNS_ALT_SERVER"                     = var.webapp_dns.secondary
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.aiutility.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "AzureAd__ClientId"                          = var.chat_api_client_id
    "AzureAd__TenantId"                          = data.azurerm_client_config.current.tenant_id
    "AzureAd__Audience"                          = "api://aiutility-web-api"
    "AzureAd__ClientSecret"                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.aiutility.name};SecretName=${data.azurerm_key_vault_secret.webapi_chat_client_secret.name})"
    "CosmosDb__Endpoint"                         = azurerm_cosmosdb_account.aiutility.endpoint
    "FrontendOrigin"                             = "https://${var.chat_settings.frontend_public_fqdn}"
    "Guardian__BaseUrl"                          = var.custom_apim_endpoint # azurerm_api_management.aiutility.gateway_url
    "Guardian__AdminApiKey"                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.aiutility.name};SecretName=${azurerm_key_vault_secret.apim_admin_subscription_key.name})"
    "Guardian__DeploymentName"                   = azurerm_cognitive_deployment.openai_models["gpt-4o"].name
    "Guardian__DefaultSku"                       = var.chat_settings.aiutility_chat_deployment_name
    "RAG__WorkspacesApiScopes"                   = var.chat_settings.workspace_api_scopes
    "RAG__WorkspaceSearchEndpoint"               = "https://${azurerm_linux_web_app.workspace_api.default_hostname}"
    "WEBSITE_ENABLE_APP_SERVICE_STORAGE"         = "false"
  }
}

data "azurerm_monitor_diagnostic_categories" "webapi_app_diagnostic" {
  resource_id = azurerm_linux_web_app.webapi_chat.id
}

resource "azurerm_monitor_diagnostic_setting" "webapi_app_diagnostic" {
  name                       = "${azurerm_linux_web_app.webapi_chat.name}-diagnostic"
  target_resource_id         = azurerm_linux_web_app.webapi_chat.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.webapi_app_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.webapi_app_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_role_assignment" "webchat_api_is_secrets_user_on_kv" {
  scope                = azurerm_key_vault.aiutility.id
  principal_id         = azurerm_linux_web_app.webapi_chat.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  description          = "Managed by Terraform - Allows the chat application's web api to retrieve secrets from the key vault"
}

resource "azurerm_cosmosdb_sql_role_assignment" "webchat_api_is_contributor_on_cosmos" {
  account_name        = azurerm_cosmosdb_account.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  principal_id        = azurerm_linux_web_app.webapi_chat.identity[0].principal_id
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.contributor.id
  scope               = azurerm_cosmosdb_account.aiutility.id
}

resource "azurerm_private_endpoint" "webapp_webapi" {
  name                          = "${azurerm_linux_web_app.webapi_chat.name}-sites-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_linux_web_app.webapi_chat.name}-sites-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_linux_web_app.webapi_chat.name}-sites"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.webapi_chat.id
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.app_service_dns_zone_id]
  }
}

output "chat_api_webapp_name" {
  value = azurerm_linux_web_app.webapi_chat.name
}

output "chat_api_public_base_url" {
  # value = "https://${azurerm_linux_web_app.webapi_chat.default_hostname}" # TODO: update with public FQDN once available
  value = "https://${var.chat_settings.webapi_public_fqdn}"
}
