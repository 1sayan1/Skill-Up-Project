variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "my-rg"
}

variable "location" {
  description = "Name of the region"
  type        = string
  default     = "westus"
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin Username"
  type        = string
  default     = "Sayan"
}

variable "admin_password" {
  description = "Admin Password"
  type        = string
  sensitive   = true
}