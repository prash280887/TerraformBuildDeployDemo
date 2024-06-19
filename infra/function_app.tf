resource "azurerm_linux_function_app" "backend" {
  depends_on = [
    azurerm_private_endpoint.storage_function_blob,
    azurerm_private_endpoint.storage_function_queue,
    azurerm_private_endpoint.storage_function_table,
    azurerm_private_endpoint.storage_function_file,
  ]

  name                                     = var.function_settings.name
  location                                 = data.azurerm_resource_group.aiutility.location
  resource_group_name                      = data.azurerm_resource_group.aiutility.name
  service_plan_id                          = azurerm_service_plan.aiutility.id
  storage_account_name                     = azurerm_storage_account.function.name
  storage_account_access_key               = azurerm_storage_account.function.primary_access_key
  virtual_network_subnet_id                = data.azurerm_subnet.app_service.id
  public_network_access_enabled            = false
  https_only                               = true
  functions_extension_version              = "~4"
  ftp_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      use_dotnet_isolated_runtime = true
      dotnet_version              = "8.0"
    }

    always_on                              = true
    ftps_state                             = "Disabled"
    http2_enabled                          = true
    websockets_enabled                     = true
    health_check_path                      = "/healthz"
    minimum_tls_version                    = "1.2"
    scm_use_main_ip_restriction            = true
    scm_minimum_tls_version                = "1.2"
    vnet_route_all_enabled                 = true
    application_insights_connection_string = azurerm_application_insights.aiutility.connection_string
  }

  app_settings = {
    ApiManagementServiceName                       = var.apim_settings.name
    CosmosDb__Endpoint                             = azurerm_cosmosdb_account.aiutility.endpoint
    CosmosDb__DatabaseName                         = azurerm_cosmosdb_sql_database.backend.name
    BlobServiceEndpoint                            = azurerm_storage_account.content.primary_blob_endpoint
    QuotaContainerName                             = azurerm_cosmosdb_sql_container.quotas.name
    ResourceGroupName                              = data.azurerm_resource_group.aiutility.name
    StorageProvider                                = "cosmos"
    GuardianProductPrefix                          = "openai-"
    GuardianConsumerApiIds                         = join(",", [azurerm_api_management_api.aiutility_consumer.name, azurerm_api_management_api.azure_openai_service_api.name])
    SubscriptionId                                 = data.azurerm_client_config.current.subscription_id
    TenantId                                       = data.azurerm_client_config.current.tenant_id
    LogAnalytics__Workspaces__default__WorkspaceId = azurerm_log_analytics_workspace.aiutility.workspace_id
    FUNCTIONS_WORKER_RUNTIME                       = "dotnet-isolated"
    SCM_DO_BUILD_DURING_DEPLOYMENT                 = "false"
    WEBSITE_CONTENTSHARE                           = azurerm_storage_share.backend_func.name
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING       = azurerm_storage_account.function.primary_connection_string
  }
}

data "azurerm_monitor_diagnostic_categories" "function_app_diagnostic" {
  resource_id = azurerm_linux_function_app.backend.id
}

resource "azurerm_monitor_diagnostic_setting" "function_app_diagnostic" {
  name                       = "${var.function_settings.name}-diagnostic"
  target_resource_id         = azurerm_linux_function_app.backend.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.function_app_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.function_app_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "backend_func_is_cosmosdb_contributor" {
  account_name        = azurerm_cosmosdb_account.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.contributor.id
  principal_id        = azurerm_linux_function_app.backend.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.aiutility.id
}

resource "azurerm_role_assignment" "backend_func_is_apim_contributor" {
  scope                = azurerm_api_management.aiutility.id
  role_definition_name = "API Management Service Contributor"
  principal_id         = azurerm_linux_function_app.backend.identity[0].principal_id
  description          = "Managed by Terraform - Allows Aiutility backend function to register users into APIM"
}

data "azurerm_function_app_host_keys" "aiutility" {
  name                = azurerm_linux_function_app.backend.name
  resource_group_name = data.azurerm_resource_group.aiutility.name

  depends_on = [azurerm_private_endpoint.backend_function]
}

resource "azurerm_key_vault_secret" "function" {
  name            = "functionApiKey"
  value           = data.azurerm_function_app_host_keys.aiutility.default_function_key
  key_vault_id    = azurerm_key_vault.aiutility.id
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

resource "azurerm_private_endpoint" "backend_function" {
  name                          = "${azurerm_linux_function_app.backend.name}-sites-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_linux_function_app.backend.name}-sites-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_linux_function_app.backend.name}-sites"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_function_app.backend.id
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.app_service_dns_zone_id]
  }
}

resource "azurerm_role_assignment" "backend_func_is_blob_contributor_on_content_storage" {
  scope                = azurerm_storage_account.content.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_function_app.backend.identity[0].principal_id
  description          = "Managed by Terraform - Allows AIUtility backend function to read and write to content storage, (reports, terms of use..)"
}

resource "azurerm_role_assignment" "func_kv_secret_user" {
  scope                = azurerm_key_vault.aiutility.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_function_app.backend.identity[0].principal_id
  description          = "Managed by Terraform - Allow the web app to read secrets from the key vault"
}

resource "azurerm_role_assignment" "backend_func_is_contributor_on_log_analytics" {
  scope                = azurerm_log_analytics_workspace.aiutility.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_linux_function_app.backend.identity[0].principal_id
  description          = "Managed by Terraform - Allows the backend function to write logs to the log analytics workspace"
}

output "backend_function_name" {
  value = azurerm_linux_function_app.backend.name
}
