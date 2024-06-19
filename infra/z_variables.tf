variable "environment" {
  type = string
}

variable "azurerm_resource_group_name" {
  type        = string
  description = "Resource Group Name from Azure for deployment into this environment"
}
variable "private_deployment" {
  description = "Flag indicating if the deployment is private"
  type        = bool
}

variable "key_vault_settings" {
  description = "Settings for Azure Key Vault"
  type = object({
    name = string
  })
}

variable "app_insights_settings" {
  description = "Settings for Azure Application Insights"
  type = object({
    name = string
  })
}

variable "apim_settings" {
  description = "Settings for Azure API Management"
  type = object({
    name            = string
    sku             = string
    publisher_email = string
    publisher_name  = string
    public_ip_name  = string
  })
}

variable "storage_account_function_settings" {
  description = "Settings for Azure Storage Account"
  type = object({
    name             = string
    tier             = string
    replication_type = string
    kind             = string
  })
}
variable "function_settings_workspaces" {
  description = "Settings for Azure Functions"
  type = object({
    name                             = string
    chunk_size                       = number
    chunk_overlap                    = number
    upload_batch_size                = number
    openAI_embedding_deployment_name = string
    openai_endpoint                  = string
  })
}

variable "storage_account_content_settings" {
  description = "Settings for the Content Azure Storage Account"
  type = object({
    name                                     = string
    tier                                     = string
    replication_type                         = string
    kind                                     = string
    reports_container_name                   = string
    blobstorage_connectionstring_secret_name = string
  })
}

variable "storage_account_config_settings" {
  description = "Settings for the Config Azure Storage Account"
  type = object({
    name                  = string
    tier                  = string
    replication_type      = string
    kind                  = string
    config_container_name = string
  })
}

variable "log_analytics_workspace_settings" {
  description = "Settings for Azure Log Analytics Workspace"
  type = object({
    name = string
  })
}
### 01 openai service ###
variable "oai_account_name" {
  type        = string
  default     = "az-openai-account"
  description = "The name of the OpenAI service."
}

variable "oai_sku_name" {
  type        = string
  description = "SKU name of the OpenAI service."
  default     = "S0"
}

variable "oai_custom_subdomain_name" {
  type        = string
  description = "The subdomain name used for token-based authentication. Changing this forces a new resource to be created. (normally the same as the account name)"
  default     = "demo-account"
}

variable "oai_dynamic_throttling_enabled" {
  type        = bool
  default     = true
  description = "Whether or not dynamic throttling is enabled. Defaults to `true`."
}

variable "oai_fqdns" {
  type        = list(string)
  default     = []
  description = "A list of FQDNs to be used for token-based authentication. Changing this forces a new resource to be created."
}

variable "oai_local_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`."
}

variable "oai_outbound_network_access_restricted" {
  type        = bool
  default     = false
  description = "Whether or not outbound network access is restricted. Defaults to `false`."
}

variable "oai_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether or not public network access is enabled. Defaults to `false`."
}

variable "oai_customer_managed_key" {
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
    type = object({
      key_vault_key_id   = (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this OpenAI Account.
      identity_client_id = (Optional) The Client ID of the User Assigned Identity that has access to the key. This property only needs to be specified when there're multiple identities attached to the OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
  description = <<-DESCRIPTION
    type = object({
      type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
      identity_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_network_acls" {
  type = set(object({
    default_action = string
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  }))
  default     = null
  description = <<-DESCRIPTION
    type = set(object({
      default_action = (Required) The Default Action to use when no rules match from ip_rules / virtual_network_rules. Possible values are `Allow` and `Deny`.
      ip_rules       = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Cognitive Account.
      virtual_network_rules = optional(set(object({
        subnet_id                            = (Required) The ID of a Subnet which should be able to access the OpenAI Account.
        ignore_missing_vnet_service_endpoint = (Optional) Whether ignore missing vnet service endpoint or not. Default to `false`.
      })))
    }))
  DESCRIPTION
}

variable "oai_storage" {
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
    type = list(object({
      storage_account_id = (Required) Full resource id of a Microsoft.Storage resource.
      identity_client_id = (Optional) The client ID of the managed identity associated with the storage resource.
    }))
  DESCRIPTION
  nullable    = false
}

variable "oai_model_deployment" {
  type = list(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    scale_type      = string
    scale_tier      = optional(string)
    scale_size      = optional(number)
    scale_family    = optional(string)
    scale_capacity  = optional(number)
    rai_policy_name = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
      type = list(object({
        deployment_id   = (Required) The name of the Cognitive Services Account `Model Deployment`. Changing this forces a new resource to be created.
        model_name = {
          model_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.
          model_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Cognitive Services Account Deployment model.
        }
        scale = {
          scale_type     = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.
          scale_tier     = (Optional) Possible values are Free, Basic, Standard, Premium, Enterprise. Changing this forces a new resource to be created.
          scale_size     = (Optional) The SKU size. When the name field is the combination of tier and some other value, this would be the standalone code. Changing this forces a new resource to be created.
          scale_family   = (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here. Changing this forces a new resource to be created.
          scale_capacity = (Optional) Tokens-per-Minute (TPM). If the SKU supports scale out/in then the capacity integer should be included. If scale out/in is not possible for the resource this may be omitted. Default value is 1. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
      }))
  DESCRIPTION
  nullable    = false
}
### 01 openai secondary service ###
variable "oai_secondary_account_name" {
  type        = string
  default     = "az-openai-account"
  description = "The name of the OpenAI service."
}

variable "oai_secondary_location" {
  type        = string
  default     = "westus"
  description = "The location of the secondary OpenAI service."
}

variable "oai_secondary_sku_name" {
  type        = string
  description = "SKU name of the OpenAI service."
  default     = "S0"
}

variable "oai_secondary_custom_subdomain_name" {
  type        = string
  description = "The subdomain name used for token-based authentication. Changing this forces a new resource to be created. (normally the same as the account name)"
  default     = "demo-account"
}

variable "oai_secondary_dynamic_throttling_enabled" {
  type        = bool
  default     = true
  description = "Whether or not dynamic throttling is enabled. Defaults to `true`."
}

variable "oai_secondary_fqdns" {
  type        = list(string)
  default     = []
  description = "A list of FQDNs to be used for token-based authentication. Changing this forces a new resource to be created."
}

variable "oai_secondary_local_auth_enabled" {
  type        = bool
  default     = true
  description = "Whether local authentication methods is enabled for the Cognitive Account. Defaults to `true`."
}

variable "oai_secondary_outbound_network_access_restricted" {
  type        = bool
  default     = false
  description = "Whether or not outbound network access is restricted. Defaults to `false`."
}

variable "oai_secondary_public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Whether or not public network access is enabled. Defaults to `false`."
}

variable "oai_secondary_customer_managed_key" {
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default     = null
  description = <<-DESCRIPTION
    type = object({
      key_vault_key_id   = (Required) The ID of the Key Vault Key which should be used to Encrypt the data in this OpenAI Account.
      identity_client_id = (Optional) The Client ID of the User Assigned Identity that has access to the key. This property only needs to be specified when there're multiple identities attached to the OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_secondary_identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }
  description = <<-DESCRIPTION
    type = object({
      type         = (Required) The type of the Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
      identity_ids = (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this OpenAI Account.
    })
  DESCRIPTION
}

variable "oai_secondary_network_acls" {
  type = set(object({
    default_action = string
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })))
  }))
  default     = null
  description = <<-DESCRIPTION
    type = set(object({
      default_action = (Required) The Default Action to use when no rules match from ip_rules / virtual_network_rules. Possible values are `Allow` and `Deny`.
      ip_rules       = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Cognitive Account.
      virtual_network_rules = optional(set(object({
        subnet_id                            = (Required) The ID of a Subnet which should be able to access the OpenAI Account.
        ignore_missing_vnet_service_endpoint = (Optional) Whether ignore missing vnet service endpoint or not. Default to `false`.
      })))
    }))
  DESCRIPTION
}

variable "oai_secondary_storage" {
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
    type = list(object({
      storage_account_id = (Required) Full resource id of a Microsoft.Storage resource.
      identity_client_id = (Optional) The client ID of the managed identity associated with the storage resource.
    }))
  DESCRIPTION
  nullable    = false
}

variable "oai_secondary_model_deployment" {
  type = list(object({
    deployment_id   = string
    model_name      = string
    model_format    = string
    model_version   = string
    scale_type      = string
    scale_tier      = optional(string)
    scale_size      = optional(number)
    scale_family    = optional(string)
    scale_capacity  = optional(number)
    rai_policy_name = optional(string)
  }))
  default     = []
  description = <<-DESCRIPTION
      type = list(object({
        deployment_id   = (Required) The name of the Cognitive Services Account `Model Deployment`. Changing this forces a new resource to be created.
        model_name = {
          model_format  = (Required) The format of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created. Possible value is OpenAI.
          model_name    = (Required) The name of the Cognitive Services Account Deployment model. Changing this forces a new resource to be created.
          model_version = (Required) The version of Cognitive Services Account Deployment model.
        }
        scale = {
          scale_type     = (Required) Deployment scale type. Possible value is Standard. Changing this forces a new resource to be created.
          scale_tier     = (Optional) Possible values are Free, Basic, Standard, Premium, Enterprise. Changing this forces a new resource to be created.
          scale_size     = (Optional) The SKU size. When the name field is the combination of tier and some other value, this would be the standalone code. Changing this forces a new resource to be created.
          scale_family   = (Optional) If the service has different generations of hardware, for the same SKU, then that can be captured here. Changing this forces a new resource to be created.
          scale_capacity = (Optional) Tokens-per-Minute (TPM). If the SKU supports scale out/in then the capacity integer should be included. If scale out/in is not possible for the resource this may be omitted. Default value is 1. Changing this forces a new resource to be created.
        }
        rai_policy_name = (Optional) The name of RAI policy. Changing this forces a new resource to be created.
      }))
  DESCRIPTION
  nullable    = false
}
variable "app_service_plan_settings" {
  description = "Settings for Azure App Service Plan"
  type = object({
    name                      = string
    sku_name                  = string
    app_service_plan_capacity = number
    zone_redundant            = bool
  })
}
variable "cosmosdb_settings" {
  description = "Settings for Azure Cosmos DB"
  type = object({
    name = string
  })
}
variable "function_settings" {
  description = "Settings for Azure Functions"
  type = object({
    name = string
  })
}
variable "app_service_dns_zone_id" {}
variable "blob_dns_zone_id" {}
variable "queue_dns_zone_id" {}
variable "table_dns_zone_id" {}
variable "file_dns_zone_id" {}
variable "vaultcore_dns_zone_id" {}
variable "cosmos_dns_zone_id" {}
variable "openai_dns_zone_id" {}
variable "search_dns_zone_id" {}
variable "static_app_dns_zone_id" {}
variable "signalr_dns_zone_id" {}
variable "acr_dns_zone_id" {}
variable "servicebus_dns_zone_id" {}


variable "resourcegroup_rbac_contributors" {
  description = "List of contributors' object ids"
  type        = list(string)
}
variable "authorized_ip_ranges" {
  type        = list(string)
  description = "The list of authorized IP ranges for the web chat app."
}

variable "chat_settings" {
  type = object({
    frontend_name                  = string
    workspace_api_scopes           = string
    webapi_webapp_name             = string
    aiutility_chat_deployment_name = string
    frontend_location              = string
    webapi_public_fqdn             = string
    frontend_public_fqdn           = string
  })
  description = "The AI Utility web chat app settings"
}
variable "chat_api_client_id" {
  type        = string
  description = "The client ID of the chat API"
}
variable "custom_apim_endpoint" {
  description = "The custom endpoint for the APIM"
  type        = string
}

variable "search_settings" {
  type = object({
    name     = string
    sku_name = string
  })
  description = "Settings for Azure Search"
}

variable "storage_account_workspaces_settings" {
  description = "Settings for Azure Storage Account"
  type = object({
    name             = string
    tier             = string
    replication_type = string
    kind             = string
  })
}

variable "container_app_settings" {
  description = "Settings for the container app"
  type = object({
    managed_identity_name = string
    aca_environment_name  = string
  })
}
variable "workspace_api_settings" {
  description = "Settings for Azure Linux WebApp"
  type = object({
    webapi_webapp_client_id          = string
    webapi_webapp_tenant_id          = string
    webapi_webapp_uri_identifier     = string
    name                             = string
    openai_endpoint                  = string
    openAI_embedding_deployment_name = string
    allowed_origins                  = list(string)
  })
}

variable "signalr_settings" {
  description = "Settings for Azure SignalR"
  type = object({
    name         = string
    sku_name     = string
    sku_capacity = number
  })
}

variable "servicebus_settings" {
  description = "Settings for Azure Service Bus"
  type = object({
    name                         = string
    sku                          = string
    capacity                     = number
    premium_messaging_partitions = number
  })
}
variable "container_registry_settings" {
  description = "Settings for Azure Container Registry"
  type = object({
    name = string
  })
}
variable "webapp_dns" {
  description = "Custom DNS servers"
  type = object({
    primary   = string
    secondary = string
  })
}
