resource_group_name = "my-resource-group1"
location = "westus"
prefix = "myapp"
admin_username = "adminuser"
admin_password = "Sayan@1993"  # Add this line

environments = {
  dev = {
    ssh_public_key_path = "/Users/jenkins/.ssh/id_rsa_dev.pub"
  }
}
