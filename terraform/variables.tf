variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VMs."
  type        = string
}

variable "environments" {
  description = "A map of environments with SSH public key paths."
  type = map(object({
    ssh_public_key_path = string
  }))
}
