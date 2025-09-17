output "postgres_admin_password" {
  value = random_password.admin_password.result
  sensitive = true
}
