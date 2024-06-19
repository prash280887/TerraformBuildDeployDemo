resource "azurerm_linux_web_app" "workspace_api" {
  name                                     = var.workspace_api_settings.name
  resource_group_name                      = data.azurerm_resource_group.aiutility.name
  location                                 = data.azurerm_resource_group.aiutility.location
  service_plan_id                          = azurerm_service_plan.aiutility.id
  https_only                               = true
  public_network_access_enabled            = true
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

    always_on          = true
    ftps_state         = "Disabled"
    http2_enabled      = true
    websockets_enabled = false
    health_check_path  = "/healthz"
  }

  app_settings = {
    "WEBSITE_DNS_SERVER"                                = var.webapp_dns.primary
    "WEBSITE_DNS_ALT_SERVER"                            = var.webapp_dns.secondary
    "APPLICATIONINSIGHTS_CONNECTION_STRING"             = azurerm_application_insights.aiutility.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION"        = "~3"
    "AzureAd__ClientId"                                 = var.workspace_api_settings.webapi_webapp_client_id
    "AzureAd__TenantId"                                 = var.workspace_api_settings.webapi_webapp_tenant_id
    "AzureAd__Audience"                                 = var.workspace_api_settings.webapi_webapp_uri_identifier
    "Cors__AllowedOrigins"                              = join(",", var.workspace_api_settings.allowed_origins)
    "CosmosDb__Endpoint"                                = azurerm_cosmosdb_account.aiutility.endpoint
    "CosmosDb__DatabaseName"                            = azurerm_cosmosdb_sql_database.workspaces.name
    "CosmosDb__WorkspacesContainerName"                 = azurerm_cosmosdb_sql_container.workspaces.name
    "DocumentStorage__Endpoint"                         = azurerm_storage_account.workspaces_docs.primary_blob_endpoint
    "IndexationProcess__ServiceBusName"                 = azurerm_servicebus_namespace.this.name
    "IndexationProcess__QueueName"                      = azurerm_servicebus_queue.indexation_requests.name
    "KnowledgeContainer__MaxPartitionCount"             = azurerm_search_service.workspaces.partition_count
    "KnowledgeContainer__PartitionMaxSizeBytes"         = 25 * 1024 * 1024 * 1024 // 25GB
    "KnowledgeContainer__MaxIndexCount"                 = 50                      // 50 indexes max for ai search S0
    "Search__Endpoint"                                  = "https://${azurerm_search_service.workspaces.name}.search.windows.net"
    "Search__OpenAiEndpoint"                            = var.workspace_api_settings.openai_endpoint
    "Search__OpenAiApiKey"                              = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.aiutility.name};SecretName=${azurerm_key_vault_secret.apim_text_embedding.name})"
    "Search__EmbeddingDeploymentName"                   = var.workspace_api_settings.openAI_embedding_deployment_name
    "Search__DefaultVectorSearchKNearestNeighborsCount" = 3
    "Search__DefaultSearchSize"                         = 3
    "WEBSITE_ENABLE_APP_SERVICE_STORAGE"                = "false"
    "WorkspacesLifetimeManager__UtcCrontabSchedule"     = "0 2 * * *"       // every day at 2am
    "Workspaces__MaxSizeInBytes"                        = 100 * 1024 * 1024 // 100MB
    "Workspaces__DocumentMaxSizeInBytes"                = 100 * 1024 * 1024 // 100MB
    "Workspaces__MaxLifetimeInDays"                     = 90
    "RealTime__SignalRConnectionString"                 = azurerm_signalr_service.this.primary_connection_string
    "RealTime__IndexationProcessHubName"                = "workspaces.indexation"
    "RealTime__WithUriRewriting"                        = false
  }
}

data "azurerm_monitor_diagnostic_categories" "workspace_api_app_diagnostic" {
  resource_id = azurerm_linux_web_app.workspace_api.id
}

resource "azurerm_monitor_diagnostic_setting" "workspace_api_app_diagnostic" {
  name                       = "${var.workspace_api_settings.name}-diagnostic"
  target_resource_id         = azurerm_linux_web_app.workspace_api.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aiutility.id
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.workspace_api_app_diagnostic.metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.workspace_api_app_diagnostic.log_category_types
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_private_endpoint" "api" {
  name                          = "${azurerm_linux_web_app.workspace_api.name}-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_linux_web_app.workspace_api.name}-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_linux_web_app.workspace_api.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.workspace_api.id
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.app_service_dns_zone_id]
  }
}

resource "azurerm_role_assignment" "api_is_ai_search_contributor" {
  scope                = azurerm_search_service.workspaces.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  description          = "Managed by Terraform - Allow the web app to manage the Azure Search service"
}

resource "azurerm_role_assignment" "api_is_ai_search_index_data_contributor" {
  scope                = azurerm_search_service.workspaces.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  description          = "Managed by Terraform - Allow the web app to read/write index data from the Azure AI Search service"
}

resource "azurerm_cosmosdb_sql_role_assignment" "api_is_db_contributor" {
  account_name        = azurerm_cosmosdb_account.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.contributor.id
  principal_id        = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.aiutility.id
}

resource "azurerm_role_assignment" "api_is_blob_data_contributor_on_doc_processor_storage" {
  scope                = azurerm_storage_account.function.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  description          = "Managed by Terraform - Allow the web app to upload blobs to the indexer storage account"
}

resource "azurerm_role_assignment" "api_is_kv_secret_user" {
  scope                = azurerm_key_vault.aiutility.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  description          = "Managed by Terraform - Allow the web app to read secrets from the key vault"
}
resource "azurerm_role_assignment" "api_is_servicebus_message_sender" {
  scope                = azurerm_servicebus_namespace.this.id
  principal_id         = azurerm_linux_web_app.workspace_api.identity[0].principal_id
  role_definition_name = "Azure Service Bus Data Sender"
  description          = "Managed by Terraform - Allows the workspaces API to send messages (indexation requests) to the Service Bus"
}

output "workspace_api_webapp_name" {
  value = azurerm_linux_web_app.workspace_api.name
}
