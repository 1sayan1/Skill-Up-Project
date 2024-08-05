provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "main" {
  count               = length(keys(var.environments))
  name                = "${var.prefix}-pip-${element(keys(var.environments), count.index)}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  count                = length(keys(var.environments))
  name                 = "${var.prefix}-nic-${element(keys(var.environments), count.index)}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                = length(keys(var.environments))
  name                 = "${var.prefix}-vm-${element(keys(var.environments), count.index)}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  size                 = "Standard_B1s"
  admin_username       = var.admin_username

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.environments[element(keys(var.environments), count.index)].ssh_public_key_path)
  }

  tags = {
    environment = element(keys(var.environments), count.index)
  }
}

output "vm_public_ip" {
  value = [for ip in azurerm_public_ip.main : ip.ip_address]
}

output "admin_username" {
  value = var.admin_username
}
