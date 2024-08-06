resource_group_name = "my-resource-group2"
location = "westus"
prefix = "myapp"
admin_username = "adminuser"
admin_password = "Sayan@1993"  # Add this line

environments = {
  prod = {
    ssh_public_key_path = "/Users/jenkins/.ssh/id_rsa_prod.pub"
  }
}
