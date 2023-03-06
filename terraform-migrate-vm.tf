# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Define the source Hyper-V VM
data "azurerm_virtual_machine" "source_vm" {
  name                = "source-vm"
  resource_group_name = "source-resource-group"
}

# Define the target Azure resources
resource "azurerm_resource_group" "target_rg" {
  name     = "target-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "target_vnet" {
  name                = "target-vnet"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "target_subnet" {
  name                 = "target-subnet"
  resource_group_name  = azurerm_resource_group.target_rg.name
  virtual_network_name = azurerm_virtual_network.target_vnet.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_security_group" "target_nsg" {
  name                = "target-nsg"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "target_nic" {
  name                = "target-nic"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name

  ip_configuration {
    name                          = "target-nic-ipconfig"
    subnet_id                     = azurerm_subnet.target_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.target_public_ip.id
  }

  depends_on = [azurerm_network_security_group.target_nsg]
}

resource "azurerm_public_ip" "target_public_ip" {
  name                = "target-public-ip"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name
  allocation_method   = "Static"
}

resource "azurerm_storage_account" "target_storage" {
  name                     = "targetstorage${random_integer.target.id}"
  resource_group_name      = azurerm_resource_group.target_rg.name
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "random_integer" "target" {
  min = 1000
  max = 9999
}

# Define the target VM
resource "azurerm_windows_virtual_machine" "target_vm" {
  name                = "target-vm"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"

  admin_password = random_password.target.result

  network_interface_ids = [
    azurerm_network_interface.target_nic.id
  ]

  storage_os_disk {
    name              = "target-vm-os-disk"
    caching           = "ReadWrite"
    create_option    = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  

  os_profile {
  computer_name = "target-vm"
  admin_username = "adminuser"
  admin_password = random_password.target.result
  }
  
  source_image_reference {
  publisher = "MicrosoftWindowsServer"
  offer = "WindowsServer"
  sku = "2019-Datacenter"
  version = "latest"
  }
  
  depends_on = [
  azurerm_public_ip.target_public_ip,
  azurerm_storage_account.target_storage,
  ]
  }

  resource "random_password" "target" {
    length = 16
    special = true
  }

  output "rdp_connection_string" {
    value = "mstsc /v:${azurerm_public_ip.target_public_ip.ip_address}"
  }

