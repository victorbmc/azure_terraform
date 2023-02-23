provider "azurerm" {
  features {}
}

resource "azurerm_key_vault" "example" {
  name                        = "site-site-keyvault"
  location                    = "westeurope"
  resource_group_name         = "site-site-vpn-rg"
  enabled_for_disk_encryption = true
  tenant_id                   = "9b79b10b-0007-4e8a-b072-ad0c8cdc1aa5"
  sku_name                    = "standard"
  
  access_policy {
    tenant_id = "9b79b10b-0007-4e8a-b072-ad0c8cdc1aa5"
    object_id = "d5ae7a3b-ec55-4133-a3ee-4a2867e64a8a"
    secret_permissions = [
      "Backup", 
	  "Delete", 
	  "Get", 
	  "List", 
	  "Purge", 
	  "Recover", 
	  "Restore", 
	  "Set"
    ]
	
	key_permissions = [
      "Backup", 
	  "Delete", 
	  "Get", 
	  "List", 
	  "Purge", 
	  "Recover", 
	  "Restore", 
	  "Set"
    ] 
  }
}
