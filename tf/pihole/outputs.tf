output "pihole_admin_password" {
  value = random_password.pihole_admin_password.result
  sensitive = true
}

