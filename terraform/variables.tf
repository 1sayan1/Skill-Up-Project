variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
}

variable "environments" {
  description = "List of environments"
  type        = list(string)
  default     = ["dev", "int", "prod"]
}
