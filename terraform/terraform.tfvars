resource_group_name = "my-resource-group"
location            = "West Europe"
prefix              = "myapp"
admin_username      = "adminuser"
admin_password      = "Sayan@1993"
environments = {
  dev = {
    ssh_public_key_path = "/path/to/dev/ssh_public_key.pub"
  }
  prod = {
    ssh_public_key_path = "/path/to/prod/ssh_public_key.pub"
  }
}
