resource "azurerm_api_management_logger" "app_insights" {
  name                = "applicationinsights"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  resource_id         = azurerm_application_insights.aiutility.id

  application_insights {
    instrumentation_key = azurerm_application_insights.aiutility.instrumentation_key
  }
}

resource "azurerm_api_management_diagnostic" "app_insights" {
  identifier               = "applicationinsights"
  resource_group_name      = data.azurerm_resource_group.aiutility.name
  api_management_name      = azurerm_api_management.aiutility.name
  api_management_logger_id = azurerm_api_management_logger.app_insights.id

  sampling_percentage = 100
  always_log_errors   = true
  log_client_ip       = true
  verbosity           = "information"

  frontend_request {
    body_bytes = 0
  }

  frontend_response {
    body_bytes = 0
  }

  backend_request {
    body_bytes = 8192
  }

  backend_response {
    body_bytes = 8192
  }
}

resource "azurerm_monitor_diagnostic_setting" "apim" {
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.aiutility.id
  name                           = "default"
  target_resource_id             = azurerm_api_management.aiutility.id

  enabled_log {
    category_group = "allLogs"
  }

  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

resource "azurerm_resource_group_template_deployment" "apim_apis_azmonitor_config" {
  resource_group_name = data.azurerm_resource_group.aiutility.name
  deployment_mode     = "Incremental"
  name                = "apim-apis-azmonitor-config-${local.apim_apis_azmonitor_config_template.metadata["_generator"].templateHash}"
  template_content    = jsonencode(local.sanitized_apim_apis_azmonitor_config_template)
  parameters_content = jsonencode({
    apimName = {
      value = azurerm_api_management.aiutility.name
    }
  })
}
