environment                 = "dev"
azurerm_resource_group_name = "corp-aiutility-main-rg"
private_deployment          = true

resourcegroup_rbac_contributors = ["07691ecb-a8e5-4036-b1ae-af3d13b48463"] # u-Corp-Architects

log_analytics_workspace_settings = {
  name = "corp-aiutility-la-dev"
}
key_vault_settings = {
  name = "corp-aiutility-kv-dev"
}
app_insights_settings = {
  name = "corp-aiutility-appin-dev"
}

apim_settings = {
  name            = "corp-aiutility-apim-dev"
  sku             = "Premium_1"
  publisher_email = "adam_bloom@ajgco.com"
  publisher_name  = "AJG Corp AI Utility"
  public_ip_name  = "corp-aiutility-apim-pip-dev"
}

storage_account_function_settings = {
  name             = "corpfsdevfunction"
  tier             = "Standard"
  replication_type = "LRS"
  kind             = "StorageV2"
}

storage_account_content_settings = {
  name                                     = "corpfsdevcontent"
  tier                                     = "Standard"
  replication_type                         = "LRS"
  kind                                     = "StorageV2"
  reports_container_name                   = "reports"
  blobstorage_connectionstring_secret_name = "blobConnectionString"
}

storage_account_config_settings = {
  name                  = "corpfsdevconfig"
  tier                  = "Standard"
  replication_type      = "LRS"
  kind                  = "StorageV2"
  config_container_name = "config"
}
### 01 Create OpenAI Service ###
oai_account_name                       = "corp-aiutility-oai-dev"
oai_sku_name                           = "S0"
oai_custom_subdomain_name              = "corp-aiutility-oai-dev"
oai_dynamic_throttling_enabled         = false # Account level throttling not supported for OpenAI
oai_fqdns                              = []
oai_local_auth_enabled                 = true
oai_outbound_network_access_restricted = true
oai_public_network_access_enabled      = false
oai_customer_managed_key               = null
oai_identity = {
  type = "SystemAssigned"
}
oai_network_acls = null
oai_storage      = null
oai_model_deployment = [
  {
    deployment_id  = "gpt-35-turbo"
    model_name     = "gpt-35-turbo"
    model_format   = "OpenAI"
    model_version  = "0613"
    scale_type     = "Standard"
    scale_capacity = 20
  },
  {
    deployment_id  = "gpt-4"
    model_name     = "gpt-4"
    model_format   = "OpenAI"
    model_version  = "0613"
    scale_type     = "Standard"
    scale_capacity = 10
  },
  {
    deployment_id  = "gpt-4o"
    model_name     = "gpt-4o"
    model_format   = "OpenAI"
    model_version  = "2024-05-13"
    scale_type     = "GlobalStandard"
    scale_capacity = 100
  },
  {
    deployment_id  = "text-embedding-ada-002"
    model_name     = "text-embedding-ada-002"
    model_format   = "OpenAI"
    model_version  = "2"
    scale_type     = "Standard"
    scale_capacity = 30
  },
]
## 02 Create OpenAI Secondary Service for Load Balancing ###
oai_secondary_location                           = "eastus"
oai_secondary_account_name                       = "corp-aiutility-oaieast-dev"
oai_secondary_sku_name                           = "S0"
oai_secondary_custom_subdomain_name              = "corp-aiutility-oaieast-dev"
oai_secondary_dynamic_throttling_enabled         = false # Account level throttling not supported for OpenAI
oai_secondary_fqdns                              = []
oai_secondary_local_auth_enabled                 = true
oai_secondary_outbound_network_access_restricted = true
oai_secondary_public_network_access_enabled      = false
oai_secondary_customer_managed_key               = null
oai_secondary_identity = {
  type = "SystemAssigned"
}
oai_secondary_network_acls = null
oai_secondary_storage      = null
oai_secondary_model_deployment = [
  {
    deployment_id  = "gpt-4o"
    model_name     = "gpt-4o"
    model_format   = "OpenAI"
    model_version  = "2024-05-13"
    scale_type     = "Standard"
    scale_capacity = 100
  }
]
app_service_plan_settings = {
  name                      = "corp-aiutility-asp-dev"
  sku_name                  = "P1v3"
  app_service_plan_capacity = 1
  zone_redundant            = false
}
cosmosdb_settings = {
  name = "corp-aiutility-cosmosdb-dev"
}
function_settings = {
  name = "corp-aiutility-function-dev"
}

app_service_dns_zone_id = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
blob_dns_zone_id        = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
queue_dns_zone_id       = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
table_dns_zone_id       = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
file_dns_zone_id        = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
vaultcore_dns_zone_id   = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
cosmos_dns_zone_id      = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
openai_dns_zone_id      = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
search_dns_zone_id      = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.search.windows.net"
static_app_dns_zone_id  = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.5.azurestaticapps.net"
signalr_dns_zone_id     = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.service.signalr.net"
acr_dns_zone_id         = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
servicebus_dns_zone_id  = "/subscriptions/9b2f9fb3-2e3c-4a93-833a-9bdda2da2ecd/resourceGroups/dns-main-rg/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"


authorized_ip_ranges = []

chat_settings = {
  frontend_name                  = "corp-aiutility-staticwebapp-dev"
  webapi_webapp_name             = "corp-aiutility-web-dev"
  aiutility_chat_deployment_name = "aiutility-chat"
  workspace_api_scopes           = "api://aiutility-web-api/Read.Write.All"
  frontend_location              = "eastus2"
  webapi_public_fqdn             = "aiutility-dev-api.ajgco.com"
  frontend_public_fqdn           = "aiutility-dev.ajgco.com"
}
search_settings = {
  name     = "corp-aiutility-search-dev"
  sku_name = "standard"
}

function_settings_workspaces = {
  name                             = "corp-aiutility-func-workspace-dev"
  chunk_size                       = 700
  chunk_overlap                    = 100
  upload_batch_size                = 100
  openAI_embedding_deployment_name = "text-embedding-ada-002"
  openai_endpoint                  = "https://aiutility-apim-dev-gateway.ajgco.com" # APIM Endpoint
}
chat_api_client_id = "03c28e62-2e72-4771-98b0-7dfc7f0bade8" # Client ID for "Corp-AIUty-ChatWebClient-Dev": 03c28e62-2e72-4771-98b0-7dfc7f0bade8

custom_apim_endpoint = "https://aiutility-apim-dev-gateway.ajgco.com" # APIM Endpoint
container_registry_settings = {
  name = "corpaiutiltyacrdev"
}
storage_account_workspaces_settings = {
  name             = "corpworkspacestgdev"
  tier             = "Standard"
  replication_type = "LRS"
  kind             = "StorageV2"
}

container_app_settings = {
  managed_identity_name = "mi-docprocessor-aiutility-dev"
  aca_environment_name  = "cae-workspace-aiutility-dev"
}

workspace_api_settings = {
  name                             = "corp-aiutility-workspace-webapp-dev"
  openai_endpoint                  = "https://aiutility-apim-dev-gateway.ajgco.com"
  webapi_webapp_client_id          = "03c28e62-2e72-4771-98b0-7dfc7f0bade8"
  webapi_webapp_tenant_id          = "6cacd170-f897-4b19-ac58-46a23307b80a"
  webapi_webapp_uri_identifier     = "api://aiutility-web-api/"
  openAI_embedding_deployment_name = "text-embedding-ada-002"
  allowed_origins                  = ["https://aiutility-dev.ajgco.com"]
}

signalr_settings = {
  name         = "corp-aiutility-sigr-dev"
  sku_name     = "Standard_S1"
  sku_capacity = 1
}

servicebus_settings = {
  name                         = "corp-aiutility-sbus-dev"
  sku                          = "Premium" # Premium SKU required for Private Link
  capacity                     = 1         # 1, 2, 4, 8 or 16
  premium_messaging_partitions = 1         # 1, 2, or 4
}
webapp_dns = {
  primary   = "10.239.0.134"
  secondary = "10.240.2.106"
}
