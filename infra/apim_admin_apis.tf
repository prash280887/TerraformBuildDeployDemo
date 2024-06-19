resource "azurerm_api_management_api" "admin" {
  name                = "admin-api"
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  revision            = "1"
  display_name        = "Admin API"
  path                = "admin"
  protocols           = ["https"]

  subscription_key_parameter_names {
    header = "api-key"
    query  = "subscription-key"
  }
}

resource "azurerm_api_management_api_operation" "admin_users_delete" {
  operation_id        = "Admin_Users_Delete"
  api_name            = azurerm_api_management_api.admin.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "Delete User"
  method              = "DELETE"
  url_template        = "/users/{user-id}"

  response {
    status_code = 200
  }

  response {
    status_code = 400
  }

  template_parameter {
    name     = "user-id"
    type     = "string"
    required = true
  }
}

resource "azurerm_api_management_api_operation" "admin_users_enroll" {
  operation_id        = "Admin_Users_Enroll"
  api_name            = azurerm_api_management_api.admin.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "Enroll User"
  method              = "POST"
  url_template        = "/users/enroll"

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    representation {
      content_type = "application/json"
    }
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "quota_get" {
  operation_id        = "Quota_Get"
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  display_name        = "Get quota"
  method              = "GET"
  url_template        = "/quota"

  response {
    representation {
      content_type = "application/json"
    }
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "admin_legal_tou_get" {
  operation_id        = "Admin_Legal_Tou_Get"
  api_management_name = azurerm_api_management.aiutility.name
  api_name            = azurerm_api_management_api.admin.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  display_name        = "Get Terms of Use"
  method              = "GET"
  url_template        = "/legal/tou"
  response {
    status_code = 200
    representation {
      content_type = "text/markdown"
    }
  }
}

resource "azurerm_api_management_api_operation" "admin_legal_tou_set" {
  operation_id        = "Admin_Legal_Tou_Set"
  api_management_name = azurerm_api_management.aiutility.name
  api_name            = azurerm_api_management_api.admin.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  display_name        = "Set Terms of Use"
  method              = "POST"
  url_template        = "/legal/tou"
  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "admin_reporting_generate" {
  operation_id        = "Admin_Reporting_Generate"
  api_management_name = azurerm_api_management.aiutility.name
  api_name            = azurerm_api_management_api.admin.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
  display_name        = "Generate Report"
  method              = "POST"
  url_template        = "/reporting/generate/{report-name}"

  template_parameter {
    name     = "report-name"
    type     = "string"
    required = true
  }

  response {
    status_code = 200
  }

  response {
    status_code = 404
  }
}
