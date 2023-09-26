output "mariadb_root_password" {
  value = random_password.root_password.result
  sensitive = true
}

