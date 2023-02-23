provider "azurerm" {
  features {}
}

data "azurerm_key_vault_secret" "shared_key" {
  name         = "secret1"
  key_vault_id = "/subscriptions/f898ca44-6909-4811-aecc-86913da959e8/resourceGroups/site-site-vpn-rg/providers/Microsoft.KeyVault/vaults/site-site-keyvault"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = "site-site-vpn-rg"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = "site-site-vpn-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "GatewaySubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "site-site-vpn-rg"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.255.0/27"]
}

resource "azurerm_public_ip" "vpn_public_ip" {
  name                         = "myvpnpublicip"
  location                     = "eastus"
  resource_group_name          = "site-site-vpn-rg"
  allocation_method            = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vpngateway" {
  name                = "myvpngateway"
  location            = "eastus"
  resource_group_name = "site-site-vpn-rg"
  type                = "Vpn"
  sku                 = "VpnGw1"
  #gateway_type        = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  ip_configuration {
    name      = "myvpnpublicip"
	#subnet = subnet.id
    public_ip_address_id = azurerm_public_ip.vpn_public_ip.id
  }
}

resource "azurerm_local_network_gateway" "onpremises_gateway" {
  name                = "myonpremisesgateway"
  location            = "eastus"
  resource_group_name = "site-site-vpn-rg"
  gateway_address     = "10.1.0.1"
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_virtual_network_gateway_connection" "vpngatewayconnection" {
  name                = "myvpngatewayconnection"
  location            = "eastus"
  resource_group_name = "site-site-vpn-rg"
  virtual_network_gateway_id       = azurerm_virtual_network_gateway.vpngateway.id
  local_network_gateway_id         = azurerm_local_network_gateway.onpremises_gateway.id
  connection_type     = "IPsec"
  routing_weight       = 10
  shared_key           = "secret1"
  enable_bgp           = false
}
