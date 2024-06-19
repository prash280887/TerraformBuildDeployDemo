data "azurerm_virtual_network" "aiutility" {
  name                = local.azurerm_virtual_network_name
  resource_group_name = local.azurerm_resource_group_name
}

data "azurerm_subnet" "apim" {
  name                 = local.azurerm_apim_subnet_name
  virtual_network_name = local.azurerm_virtual_network_name
  resource_group_name  = local.azurerm_resource_group_name
}

data "azurerm_subnet" "private_endpoint" {
  name                 = local.azurerm_private_link_subnet_name
  virtual_network_name = local.azurerm_virtual_network_name
  resource_group_name  = local.azurerm_resource_group_name
}

data "azurerm_subnet" "app_service" {
  name                 = local.azurerm_webapp_subnet_name
  virtual_network_name = local.azurerm_virtual_network_name
  resource_group_name  = local.azurerm_resource_group_name
}

data "azurerm_subnet" "app_gateway" {
  name                 = local.azurerm_agw_subnet_name
  virtual_network_name = local.azurerm_virtual_network_name
  resource_group_name  = local.azurerm_resource_group_name
}
