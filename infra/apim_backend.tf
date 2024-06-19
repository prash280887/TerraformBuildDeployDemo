resource "azurerm_api_management_backend" "backend_function" {
  name                = "aoais-aiutility-func" # azurerm_linux_function_app.backend.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  protocol            = "http"
  url                 = "https://${azurerm_linux_function_app.backend.default_hostname}"
  credentials {
    header = {
      "x-functions-key" = "{{${azurerm_api_management_named_value.aiutility_backend_apikey.name}}}"
    }
  }
  tls {
    validate_certificate_chain = true
    validate_certificate_name  = true
  }
}
