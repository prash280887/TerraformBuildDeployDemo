# NOTE: using azapi until this PR https://github.com/hashicorp/terraform-provider-azurerm/pull/24277 or similar is merged
# Issues:
# - https://github.com/hashicorp/terraform-provider-azurerm/issues/24596
# - https://github.com/hashicorp/terraform-provider-azurerm/issues/24608
resource "azapi_resource" "container_app_environment" {
  parent_id = data.azurerm_resource_group.aiutility.id
  location  = data.azurerm_resource_group.aiutility.location
  name      = var.container_app_settings.aca_environment_name
  type      = "Microsoft.App/managedEnvironments@2023-05-01"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.aiutility.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.aiutility.primary_shared_key
        }
      }
      zoneRedundant = false
      workloadProfiles = [
        {
          workloadProfileType = "Consumption"
          name                = "Consumption"
        }
      ]
      infrastructureResourceGroup = "mrg-${var.container_app_settings.aca_environment_name}"
    }
  })
}

output "aca_environment_name" {
  value = azapi_resource.container_app_environment.name
}

output "aca_environment_id" {
  value = azapi_resource.container_app_environment.id
}

resource "azurerm_user_assigned_identity" "worker" {
  name                = var.container_app_settings.managed_identity_name
  location            = data.azurerm_resource_group.aiutility.location
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

output "worker_identity_client_id" {
  value = azurerm_user_assigned_identity.worker.client_id
}

resource "azurerm_role_assignment" "worker_can_read_keyvault_secrets" {
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.aiutility.id
  principal_id         = azurerm_user_assigned_identity.worker.principal_id
  description          = "Managed by Terraform - Allow the worker to read secrets from the Key Vault"
}

resource "azurerm_role_assignment" "worker_can_pull_from_registry" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.aiutility.id
  principal_id         = azurerm_user_assigned_identity.worker.principal_id
  description          = "Managed by Terraform - Allow the worker to pull images from the source registry"
}
resource "azurerm_cosmosdb_sql_role_assignment" "worker_is_cosmosdb_contributor" {
  account_name        = azurerm_cosmosdb_account.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  role_definition_id  = data.azurerm_cosmosdb_sql_role_definition.contributor.id
  principal_id        = azurerm_user_assigned_identity.worker.principal_id
  scope               = azurerm_cosmosdb_account.aiutility.id
}

resource "azurerm_role_assignment" "worker_is_search_index_data_contributor_on_ai_search" {
  scope                = azurerm_search_service.workspaces.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.worker.principal_id
  description          = "Managed by Terraform - Allows Workspace doc processor worker to read and write to Azure AI Search Indexes"
}

resource "azurerm_role_assignment" "worker_is_servicebus_message_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  principal_id         = azurerm_user_assigned_identity.worker.principal_id
  role_definition_name = "Azure Service Bus Data Receiver"
  description          = "Allows the worker to receive messages from the Service Bus"
}

resource "azurerm_key_vault_secret" "servicebus_connection_string" {
  key_vault_id    = azurerm_key_vault.aiutility.id
  value           = azurerm_servicebus_namespace.this.default_primary_connection_string
  name            = "servicebus-connection"
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

output "servicebus_connection_string_secret_url" {
  value = azurerm_key_vault_secret.servicebus_connection_string.versionless_id
}

resource "azurerm_key_vault_secret" "openai_api_key" {
  key_vault_id    = azurerm_key_vault.aiutility.id
  value           = azurerm_api_management_subscription.text_embedding.primary_key
  name            = "worker-openai-key"
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

output "openai_api_key_secret_url" {
  value = azurerm_key_vault_secret.openai_api_key.versionless_id
}

resource "azurerm_key_vault_secret" "signalr_connection_string" {
  key_vault_id    = azurerm_key_vault.aiutility.id
  value           = azurerm_signalr_service.this.primary_connection_string
  name            = "signalr-connection"
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  key_vault_id    = azurerm_key_vault.aiutility.id
  value           = azurerm_storage_account.workspaces_docs.primary_connection_string
  name            = "storage-connection"
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

resource "azurerm_key_vault_secret" "app_insights_connection_string" {
  key_vault_id    = azurerm_key_vault.aiutility.id
  value           = azurerm_application_insights.aiutility.connection_string
  name            = "app-insights-connection"
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin]
}

output "signalr_connection_string_secret_url" {
  value = azurerm_key_vault_secret.signalr_connection_string.versionless_id
}

output "storage_connection_string_secret_url" {
  value = azurerm_key_vault_secret.storage_connection_string.versionless_id
}

output "worker_identity_id" {
  value = azurerm_user_assigned_identity.worker.id
}

output "container_registry_server" {
  value = azurerm_container_registry.aiutility.login_server
}

output "openai_endpoint" {
  value = var.workspace_api_settings.openai_endpoint
}

output "openai_embedding_deployment_name" {
  value = var.workspace_api_settings.openAI_embedding_deployment_name
}

output "app_insights_connection_string_secret_url" {
  value = azurerm_key_vault_secret.app_insights_connection_string.versionless_id
}
