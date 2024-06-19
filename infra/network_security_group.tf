resource "azurerm_network_security_group" "apim" {
  name                = "aiutility-nsg" # max 10 lowerchase characters
  location            = data.azurerm_resource_group.aiutility.location
  resource_group_name = data.azurerm_resource_group.aiutility.name

  security_rule {
    name                       = "AllowAPIMManagementEndpoint"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowClientCommunication"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowAPIManagementOutbound"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "ApiManagement"
  }
  security_rule {
    name                       = "AllowOutboundStorage"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage"
  }
  security_rule {
    name                       = "AllowAAD"
    priority                   = 145
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureActiveDirectory"
  }
  security_rule {
    name                       = "AllowAzureConnectors"
    priority                   = 146
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureConnectors"
  }
  security_rule {
    name                       = "AllowSQL"
    priority                   = 147
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "Sql"
  }
  security_rule {
    name                       = "AllowOutboundSQL"
    priority                   = 150
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "SQL"
  }

  security_rule {
    name                       = "AllowOutboundKeyVault"
    priority                   = 160
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureKeyVault"
  }
  security_rule {
    name                       = "AllowFilShare"
    priority                   = 161
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "*"
    destination_address_prefix = "Storage"
  }
  security_rule {
    name                       = "AllowEventHub"
    priority                   = 165
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["5671", "5672", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "EventHub"
  }
  security_rule {
    name                       = "AllowOutboundAzureMonitor"
    priority                   = 170
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["1886", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }
  security_rule {
    name                       = "AllowVnetToVnet"
    priority                   = 2090
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "AllowCognitiveServicesManagement"
    priority                   = 2080
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
    source_address_prefix      = "*"
    destination_address_prefix = "CognitiveServicesManagement"
  }
  security_rule {
    name                       = "DenySMTPRelay"
    priority                   = 3000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
    destination_port_ranges    = ["25", "587", "25028"]
  }
}

resource "azurerm_subnet_network_security_group_association" "apim_to_subnet" {
  subnet_id                 = data.azurerm_subnet.apim.id
  network_security_group_id = azurerm_network_security_group.apim.id
}
