resource "azurerm_api_management_subscription" "default" {
  resource_group_name = data.azurerm_resource_group.aiutility.name
  api_management_name = azurerm_api_management.aiutility.name
  product_id          = azurerm_api_management_product.admin.id
  display_name        = "default-admin-subscription"
  state               = "active"
}

resource "azurerm_key_vault_secret" "apim_admin_subscription_key" {
  name            = "apimAdminSubscriptionKey"
  value           = azurerm_api_management_subscription.default.primary_key
  key_vault_id    = azurerm_key_vault.aiutility.id
  expiration_date = time_rotating.secret_rotation.rotation_rfc3339

  depends_on = [azurerm_role_assignment.deployer_is_kv_admin, azurerm_private_endpoint.key_vault]
}
