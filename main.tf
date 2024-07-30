terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.2"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "vm" {
  source                = "./vm-module"
  environment           = var.environment
  resource_group_name   = var.resource_group_name
  location              = var.location
  vm_size               = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}
