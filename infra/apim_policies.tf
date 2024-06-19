resource "azapi_resource" "fragment_aiutility_getconfig" {
  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-getconfig"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "sets the aiutility-config variable"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-getconfig-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_getmappingconfig" {
  depends_on = [azurerm_api_management_named_value.aiutility_mapping_blob_url]

  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-getmappingconfig"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "loads the mapping configuration from the blob storage if needed, and sets the aiutility-mapping variable"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-getmappingconfig-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_getquota" {
  depends_on = [azurerm_api_management_named_value.aiutility_backend_endpoint, azurerm_api_management_named_value.aiutility_backend_apikey]

  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-getquota"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "retrieves the quota from the backend and sets the aiutility-quota variable"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-getquota-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_invalidateconfig" {
  depends_on = [azurerm_api_management_named_value.aiutility_backend_endpoint, azurerm_api_management_named_value.aiutility_backend_apikey]

  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-invalidateconfig"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "invalidates the aiutility-mapping variable"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-invalidateconfig-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_returnresponse403" {
  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-returnresponse403"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "returns a 403 response with the aiutility error message"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-returnresponse403-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_saveconsumedtokens" {
  depends_on = [azurerm_api_management_named_value.aiutility_backend_endpoint, azurerm_api_management_named_value.aiutility_backend_apikey]

  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-saveconsumedtokens"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "persists consumed token"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-saveconsumedtokens-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_setbackend" {
  depends_on = [azurerm_api_management_named_value.aiutility_backend_endpoint, azurerm_api_management_named_value.aiutility_backend_apikey]

  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-setbackend"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "configures the backend for the request and handles response RateLimit headers"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-setbackend-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_aiutility_setquotaheaders" {
  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "aiutility-setquotaheaders"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "transforms Aiutility quota to response RateLimit headers"
      format      = "rawxml"
      value       = file("${local.fragments_path}/aiutility-setquotaheaders-fragmentPolicy.xml")
    }
  })
}

resource "azapi_resource" "fragment_openai_getconsumedtokens" {
  type      = "Microsoft.ApiManagement/service/policyfragments@2023-03-01-preview"
  name      = "openai-getconsumedtokens"
  parent_id = azurerm_api_management.aiutility.id

  body = jsonencode({
    properties = {
      description = "defines the OpenAI consumed tokens variables from the backend response"
      format      = "rawxml"
      value       = file("${local.fragments_path}/openai-getconsumedtokens-fragmentPolicy.xml")
    }
  })

  depends_on = [azurerm_api_management_named_value.aiutility_backend_endpoint, azurerm_api_management_named_value.aiutility_backend_apikey]
}

resource "azurerm_api_management_policy" "global_service_policy" {
  api_management_id = azurerm_api_management.aiutility.id
  xml_content       = file("${local.policies_definitions_path}/globalServicePolicy.xml")
}

resource "azurerm_api_management_api_policy" "admin_api_policy" {
  api_name            = azurerm_api_management_api.admin.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  xml_content         = file("${local.policies_definitions_path}/admin-api-apiPolicy.xml")

  depends_on = [
    azurerm_api_management_backend.backend_function
  ]
}

resource "azurerm_api_management_api_policy" "azure_openai_service_api_policy" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  xml_content         = file("${local.policies_definitions_path}/azure-openai-service-api-apiPolicy.xml")

  depends_on = [
    azurerm_api_management_backend.backend_function,
    azapi_resource.fragment_aiutility_getmappingconfig,
    azapi_resource.fragment_aiutility_getconfig,
    azapi_resource.fragment_aiutility_getquota,
    azapi_resource.fragment_aiutility_invalidateconfig,
    azapi_resource.fragment_aiutility_returnresponse403,
    azapi_resource.fragment_aiutility_saveconsumedtokens,
    azapi_resource.fragment_aiutility_setbackend,
    azapi_resource.fragment_aiutility_setquotaheaders,
    azapi_resource.fragment_openai_getconsumedtokens
  ]
}

resource "azurerm_api_management_api_operation_policy" "chat_completions_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "ChatCompletions_Create"
  xml_content         = file("${local.policies_definitions_path}/azure-openai-service-api-ChatCompletions_Create-operationPolicy.xml")

  depends_on = [
    azapi_resource.fragment_aiutility_returnresponse403,
  ]
}

resource "azurerm_api_management_api_operation_policy" "completions_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "Completions_Create"
  xml_content         = file("${local.policies_definitions_path}/azure-openai-service-api-Completions_Create-operationPolicy.xml")

  depends_on = [
    azapi_resource.fragment_aiutility_returnresponse403,
  ]
}

resource "azurerm_api_management_api_operation_policy" "embeddings_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "embeddings_create"
  xml_content         = file("${local.policies_definitions_path}/azure-openai-service-api-embeddings_create-operationPolicy.xml")

  depends_on = [
    azapi_resource.fragment_aiutility_returnresponse403,
  ]
}
### Not available in New API Spec
###resource "azurerm_api_management_api_operation_policy" "extensions_chat_completions_create" {
###  api_name            = azurerm_api_management_api.azure_openai_service_api.name
###  api_management_name = azurerm_api_management.aiutility.name
###  resource_group_name = data.azurerm_resource_group.aiutility.name
###  operation_id        = "ExtensionsChatCompletions_Create"
###  xml_content         = file("${local.policies_definitions_path}/azure-openai-service-api-ChatCompletions_Create-operationPolicy.xml")
###
###  depends_on = [
###    azapi_resource.fragment_aiutility_returnresponse403,
###  ]
###}

resource "azurerm_api_management_api_operation_policy" "transcriptions_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "Transcriptions_Create"
  xml_content         = file("${local.policies_definitions_path}/aiutility-noop-operationPolicy.xml")
}

resource "azurerm_api_management_api_operation_policy" "translations_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "Translations_Create"
  xml_content         = file("${local.policies_definitions_path}/aiutility-noop-operationPolicy.xml")
}

resource "azurerm_api_management_api_operation_policy" "image_generations_create" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  operation_id        = "ImageGenerations_Create"
  xml_content         = file("${local.policies_definitions_path}/aiutility-noop-operationPolicy.xml")
}
