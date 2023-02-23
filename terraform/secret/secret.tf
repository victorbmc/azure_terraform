provider "azurerm" {
  features {}
}

resource "azurerm_key_vault_secret" "example" {
  name         = "secret1"
  value        = "1!Vienna"
  key_vault_id = "/subscriptions/f898ca44-6909-4811-aecc-86913da959e8/resourceGroups/site-site-vpn-rg/providers/Microsoft.KeyVault/vaults/site-site-keyvault"

  content_type = "text/plain"
}
