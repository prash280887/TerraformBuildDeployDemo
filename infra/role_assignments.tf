# Assign roles to contributors
resource "azurerm_role_assignment" "contributors" {
  count                = length(var.resourcegroup_rbac_contributors)
  scope                = data.azurerm_resource_group.aiutility.id
  role_definition_name = "AJG Contributor"
  principal_id         = var.resourcegroup_rbac_contributors[count.index]
  description          = "Managed by Terraform - Allows the contributor group to perform all actions on the resource group"
}
resource "azurerm_role_assignment" "contributor_is_kv_admin" {
  count                = length(var.resourcegroup_rbac_contributors)
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.aiutility.id
  principal_id         = var.resourcegroup_rbac_contributors[count.index]
  description          = "Managed by Terraform - Allows the contributor group to perform all actions on the key vault"
}
