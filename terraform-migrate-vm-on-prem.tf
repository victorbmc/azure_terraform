# Configure the Azure provider
provider "azurerm" {
  features {}
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
  }

  depends_on = [azurerm_network_security_group.target_nsg]
}

# Define the target VM
resource "azurerm_windows_virtual_machine" "target_vm" {
  name                = "target-vm"
  location            = "East US"
  resource_group_name = azurerm_resource_group.target_rg.name
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  source_vm_id        = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Compute/virtualMachines/<vm-name>" # Replace with the actual values from your on-premises Hyper-V VM

  network_interface_ids = [
    azurerm_network_interface.target_nic.id
  ]

  storage_os_disk {
    name              = "target-vm-os-disk"
    caching           = "ReadWrite"
    create_option     = "Attach"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "target-vm"
    admin_username = "adminuser"
  }
}

output "rdp_connection_string" {
  value = "mstsc /v:${azurerm_windows_virtual_machine.target_vm.public_ip_address}"
}
