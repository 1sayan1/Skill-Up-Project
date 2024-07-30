variable "environment" {
  description = "The environment to deploy (dev, int, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Name of the region"
  type        = string
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "admin_username" {
  description = "Admin Username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin Password"
  type        = string
  sensitive   = true
}
