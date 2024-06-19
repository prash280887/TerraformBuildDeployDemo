resource "azurerm_api_management_api_schema" "aiutility" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  schema_id           = "646cd35b4634610c082f0ca8"
  content_type        = "application/vnd.oai.openapi.components+json"
  value               = <<JSON
      {
    "properties": {
        "contentType": "application/vnd.oai.openapi.components+json",
        "document": {}
      }
    }
    JSON
}
