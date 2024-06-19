# Reference to the current connection used for
data "azurerm_client_config" "current" {}

# Reference for resource groups that need to exist
data "azurerm_resource_group" "aiutility" {
  name = var.azurerm_resource_group_name
}

# Private link subnet, comment out or rename if not required
data "azurerm_subnet" "private_link" {
  name                 = local.azurerm_private_link_subnet_name
  virtual_network_name = local.azurerm_virtual_network_name
  resource_group_name  = local.azurerm_resource_group_name
}
