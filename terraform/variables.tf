variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "eastus"
}

variable "vm_names" {
  description = "The names of the virtual machines"
  type        = list(string)
}

variable "vm_sizes" {
  description = "The sizes of the virtual machines"
  type        = list(string)
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
}
