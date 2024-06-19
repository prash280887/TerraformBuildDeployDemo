resource "azurerm_api_management_api" "aiutility_consumer" {
  name                  = "consumer-api"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  revision              = "1"
  display_name          = "Consumer API"
  description           = "API for consumer"
  path                  = "consumer"
  protocols             = ["https"]
  subscription_required = true
  api_type              = "http"
  subscription_key_parameter_names {
    header = "api-Key"
    query  = "api-key"
  }
}

resource "azurerm_api_management_api_operation" "consumer_api_get_quota" {
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_name            = azurerm_api_management_api.aiutility_consumer.name
  display_name        = "Get Quota"
  operation_id        = "Quota_Get"
  method              = "GET"
  url_template        = "/llm/{deployment-id}/quota"

  template_parameter {
    name     = "deployment-id"
    required = true
    type     = "string"
  }

  response {
    description = "OK"
    status_code = 200
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "consumer_llm_post_count_tokens" {
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_name            = azurerm_api_management_api.aiutility_consumer.name
  display_name        = "LLM Compute tokens count"
  operation_id        = "Llm_PostCountTokens"
  method              = "POST"
  url_template        = "/llm/{deployment-id}/count-tokens"

  template_parameter {
    name     = "deployment-id"
    required = true
    type     = "string"
  }

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    description = "OK"
    status_code = 200
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "consumer_api_get_quota" {
  depends_on = [
    azapi_resource.fragment_aiutility_getmappingconfig,
    azapi_resource.fragment_aiutility_getconfig,
    azapi_resource.fragment_aiutility_returnresponse403,
    azapi_resource.fragment_aiutility_getquota,
  ]

  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_name            = azurerm_api_management_api.aiutility_consumer.name
  operation_id        = azurerm_api_management_api_operation.consumer_api_get_quota.operation_id
  xml_content         = file("${local.policies_definitions_path}/consumer-api-Quota_Get-operationPolicy.xml")
}

resource "azurerm_api_management_api_operation_policy" "consumer_llm_post_count_tokens" {
  depends_on = [
    azapi_resource.fragment_aiutility_getmappingconfig,
    azapi_resource.fragment_aiutility_getconfig,
  ]

  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_name            = azurerm_api_management_api.aiutility_consumer.name
  operation_id        = azurerm_api_management_api_operation.consumer_llm_post_count_tokens.operation_id
  xml_content         = file("${local.policies_definitions_path}/consumer-api-Llm_PostCountTokens-operationPolicy.xml")
}
