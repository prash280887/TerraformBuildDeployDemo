locals {
  # Labels and common metadata required for deployment
  environment   = lower(var.environment)
  division      = "corp"
  business_unit = "102153"

  # Azure Networking
  static_app_dns_zone_name            = element(split("/", var.static_app_dns_zone_id), length(split("/", var.static_app_dns_zone_id)) - 1)
  azurerm_virtual_network_name        = "corp-dev-pvnet"
  azurerm_resource_group_name         = "network-rg"
  azurerm_private_link_subnet_name    = "pe1"                 # 10.207.16.192/26
  azurerm_webapp_subnet_name          = "vnet-integration"    # 10.207.2.128/28
  azurerm_apim_subnet_name            = "corp-apim-aiuty-dev" # 10.207.14.0/28
  azurerm_agw_subnet_name             = "corp-agw-aiutility"  # 10.207.14.32/27
  policies_definitions_path           = "./apim-policies/definitions"
  api_definitions_path                = "./apis-definitions"
  fragments_path                      = "./apim-policies/fragments"
  apim_apis_azmonitor_config_template = jsondecode(file("${path.module}/apim-azure-monitor-logs/main.json"))
  sanitized_apim_apis_azmonitor_config_template = {
    for k, v in local.apim_apis_azmonitor_config_template : k => v if k != "metadata"
  }
  aiutility_mapping = {
    "${azurerm_api_management_product.aiutility_chat.product_id}" = {
      deployments            = [azurerm_cognitive_deployment.openai_models["gpt-35-turbo"].name, azurerm_cognitive_deployment.openai_models["gpt-4o"].name, azurerm_cognitive_deployment.openai_models["gpt-4"].name]
      defaultPreprompt       = file("${path.module}/preprompts/openai-eu2.txt")
      defaultTemperature     = null
      renewalPeriodInMinutes = 30
      tokenQuotaPerPeriod    = 20000
      backends = [
        {
          endpoint = azurerm_cognitive_account.openai.endpoint
        }
      ]
    }
    "${azurerm_api_management_product.claims_summarizer.product_id}" = {
      deployments            = [azurerm_cognitive_deployment.openai_models["gpt-35-turbo"].name, azurerm_cognitive_deployment.openai_models["gpt-4o"].name, azurerm_cognitive_deployment.openai_models["text-embedding-ada-002"].name]
      defaultPreprompt       = ""
      defaultTemperature     = null
      renewalPeriodInMinutes = 1
      tokenQuotaPerPeriod    = 2147483647 # Huge quota to make quota management easier
      backends = [
        {
          endpoint = azurerm_cognitive_account.openai.endpoint
        }
      ]
    }
    "${azurerm_api_management_product.openai_aiutility_gpt4.product_id}" = {
      deployments            = [azurerm_cognitive_deployment.openai_models["gpt-4"].name]
      defaultPreprompt       = file("${path.module}/preprompts/openai-aiutility-chat-gpt4-default-prompt.txt")
      defaultTemperature     = null
      renewalPeriodInMinutes = 60
      tokenQuotaPerPeriod    = 10000
      backends = [
        {
          endpoint = azurerm_cognitive_account.openai.endpoint
        }
      ]
    }
    "${azurerm_api_management_product.openai_aiutility_gpt4o.product_id}" = {
      deployments            = [azurerm_cognitive_deployment.openai_models["gpt-4o"].name]
      defaultPreprompt       = file("${path.module}/preprompts/openai-aiutility-chat-gpt4o-default-prompt.txt")
      defaultTemperature     = null
      renewalPeriodInMinutes = 60
      tokenQuotaPerPeriod    = 10000
      backends = [
        {
          endpoint = azurerm_cognitive_account.openai.endpoint
        },
        {
          endpoint = azurerm_cognitive_account.openai_secondary.endpoint
        }
      ]
    }
    "${azurerm_api_management_product.openai_aiutility_text_embedding.product_id}" = {
      deployments            = [azurerm_cognitive_deployment.openai_models["text-embedding-ada-002"].name]
      renewalPeriodInMinutes = 1
      tokenQuotaPerPeriod    = 240000
      backends = [
        {
          endpoint = azurerm_cognitive_account.openai.endpoint
        }
      ]
    }
  }
}
