resource "azurerm_cognitive_account" "openai" {
  kind                               = "OpenAI"
  location                           = data.azurerm_resource_group.aiutility.location
  name                               = var.oai_account_name
  resource_group_name                = data.azurerm_resource_group.aiutility.name
  sku_name                           = var.oai_sku_name
  custom_subdomain_name              = var.oai_custom_subdomain_name
  dynamic_throttling_enabled         = var.oai_dynamic_throttling_enabled
  fqdns                              = var.oai_fqdns
  local_auth_enabled                 = var.oai_local_auth_enabled
  outbound_network_access_restricted = var.oai_outbound_network_access_restricted
  public_network_access_enabled      = var.oai_public_network_access_enabled
  # tags                               = var.tags

  dynamic "customer_managed_key" {
    for_each = var.oai_customer_managed_key != null ? [var.oai_customer_managed_key] : []
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }

  dynamic "identity" {
    for_each = var.oai_identity != null ? [var.oai_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_acls" {
    for_each = var.oai_network_acls != null ? [var.oai_network_acls] : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules != null ? network_acls.value.virtual_network_rules : []
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "storage" {
    for_each = var.oai_storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }
}

# Create OpenAI Cognitive Account Model Deployments
resource "azurerm_cognitive_deployment" "openai_models" {
  for_each = { for each in var.oai_model_deployment : each.deployment_id => each }

  cognitive_account_id = azurerm_cognitive_account.openai.id
  name                 = each.value.deployment_id
  rai_policy_name      = each.value.rai_policy_name

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type     = each.value.scale_type
    tier     = each.value.scale_tier
    size     = each.value.scale_size
    family   = each.value.scale_family
    capacity = each.value.scale_capacity
  }
}
resource "azurerm_private_endpoint" "openai" {
  name                          = "${azurerm_cognitive_account.openai.name}-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_cognitive_account.openai.name}-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_cognitive_account.openai.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.openai_dns_zone_id]
  }
}

resource "azurerm_cognitive_account" "openai_secondary" {
  kind                               = "OpenAI"
  location                           = var.oai_secondary_location
  name                               = var.oai_secondary_account_name
  resource_group_name                = data.azurerm_resource_group.aiutility.name
  sku_name                           = var.oai_secondary_sku_name
  custom_subdomain_name              = var.oai_secondary_custom_subdomain_name
  dynamic_throttling_enabled         = var.oai_secondary_dynamic_throttling_enabled
  fqdns                              = var.oai_secondary_fqdns
  local_auth_enabled                 = var.oai_secondary_local_auth_enabled
  outbound_network_access_restricted = var.oai_secondary_outbound_network_access_restricted
  public_network_access_enabled      = var.oai_secondary_public_network_access_enabled
  # tags                               = var.tags

  dynamic "customer_managed_key" {
    for_each = var.oai_secondary_customer_managed_key != null ? [var.oai_secondary_customer_managed_key] : []
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }

  dynamic "identity" {
    for_each = var.oai_secondary_identity != null ? [var.oai_secondary_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_acls" {
    for_each = var.oai_secondary_network_acls != null ? [var.oai_secondary_network_acls] : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = network_acls.value.ip_rules

      dynamic "virtual_network_rules" {
        for_each = network_acls.value.virtual_network_rules != null ? network_acls.value.virtual_network_rules : []
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "storage" {
    for_each = var.oai_secondary_storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }
}

# Create OpenAI Cognitive Account Model Deployments
resource "azurerm_cognitive_deployment" "openai_secondary_models" {
  for_each = { for each in var.oai_secondary_model_deployment : each.deployment_id => each }

  cognitive_account_id = azurerm_cognitive_account.openai_secondary.id
  name                 = each.value.deployment_id
  rai_policy_name      = each.value.rai_policy_name

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type     = each.value.scale_type
    tier     = each.value.scale_tier
    size     = each.value.scale_size
    family   = each.value.scale_family
    capacity = each.value.scale_capacity
  }
}
resource "azurerm_private_endpoint" "openai_secondary" {
  name                          = "${azurerm_cognitive_account.openai_secondary.name}-pe"
  location                      = data.azurerm_resource_group.aiutility.location
  resource_group_name           = data.azurerm_resource_group.aiutility.name
  subnet_id                     = data.azurerm_subnet.private_endpoint.id
  custom_network_interface_name = "${azurerm_cognitive_account.openai_secondary.name}-pe-nic"

  private_service_connection {
    name                           = "psc-${azurerm_cognitive_account.openai_secondary.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.openai_secondary.id
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.openai_dns_zone_id]
  }
}
