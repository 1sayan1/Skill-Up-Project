resource_group_name = "my-resource-group"
location            = "eastus"
prefix              = "myproject"
admin_username      = "adminuser"
environments = {
  dev = {
    ssh_public_key_path = "~/.ssh/id_rsa_dev.pub"
  }
  int = {
    ssh_public_key_path = "~/.ssh/id_rsa_int.pub"
  }
  prod = {
    ssh_public_key_path = "~/.ssh/id_rsa_prod.pub"
  }
}
