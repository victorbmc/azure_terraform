provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "site-site-vpn-rg"
  location = "westeurope"
  # subscription_id = "f898ca44-6909-4811-aecc-86913da959e8"
  # client_id       = "127abd02-4813-4893-8081-e6ab78676ba6"
  # client_secret   = "LJK8Q~kGm3kDuy3TTzSZxf.wDvwndjvmvxpSvb_W"
  # tenant_id       = "9b79b10b-0007-4e8a-b072-ad0c8cdc1aa5"
}