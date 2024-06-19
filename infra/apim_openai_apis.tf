resource "azurerm_api_management_api" "azure_openai_service_api" {
  name                = "azure-openai-service-api"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  revision            = "1"
  display_name        = "Azure OpenAI Service API"
  path                = "openai"
  protocols           = ["https"]
  import {
    content_format = "openapi+json"
    content_value  = file("${local.api_definitions_path}/azure-openai-api.openapi.json")
  }

  subscription_key_parameter_names {
    header = "api-key"
    query  = "subscription-key"
  }
}

