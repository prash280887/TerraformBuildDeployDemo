resource "azurerm_api_management_product" "admin" {
  product_id            = "admin"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "Admin api"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product" "aiutility_chat" {
  product_id            = "openai-aiutility-chat"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "openai-aiutility-chat"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product" "openai_aiutility_gpt4" {
  product_id            = "openai-aiutility-gpt4"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "openai-aiutility-gpt4"
  subscription_required = true
  approval_required     = false
  published             = true
}
resource "azurerm_api_management_product" "openai_aiutility_gpt4o" {
  product_id            = "openai-aiutility-gpt4o"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "openai-aiutility-gpt4o"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product" "claims_summarizer" {
  product_id            = "claims_summarizer"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "claims_summarizer"
  description           = "Product for the claims summarizer test application"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product_api" "summarizer_uses_openai_apis" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  product_id          = azurerm_api_management_product.claims_summarizer.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product_api" "admin" {
  api_name            = azurerm_api_management_api.admin.name
  product_id          = azurerm_api_management_product.admin.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product" "openai_aiutility_text_embedding" {
  product_id            = "openai-aiutility-text-embedding"
  resource_group_name   = data.azurerm_resource_group.aiutility.name
  api_management_name   = azurerm_api_management.aiutility.name
  display_name          = "openai-aiutility-text-embedding"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_product_api" "webchat_uses_openai_apis" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  product_id          = azurerm_api_management_product.aiutility_chat.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product_api" "webchat_uses_consumer_apis" {
  api_name            = azurerm_api_management_api.aiutility_consumer.name
  product_id          = azurerm_api_management_product.aiutility_chat.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product_api" "gpt4_uses_openai_apis" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  product_id          = azurerm_api_management_product.openai_aiutility_gpt4.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product_api" "gpt4o_uses_openai_apis" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  product_id          = azurerm_api_management_product.openai_aiutility_gpt4o.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}

resource "azurerm_api_management_product_api" "workspaces_uses_openai_apis" {
  api_name            = azurerm_api_management_api.azure_openai_service_api.name
  product_id          = azurerm_api_management_product.openai_aiutility_text_embedding.product_id
  api_management_name = azurerm_api_management.aiutility.name
  resource_group_name = data.azurerm_resource_group.aiutility.name
}
