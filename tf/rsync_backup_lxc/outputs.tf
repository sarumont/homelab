output "backup_ssh_public_key" {
  description = "Public SSH key to add to backup destinations (kolnas, rsync.net)."
  value       = tls_private_key.backup_ssh.public_key_openssh
}

output "container_ip" {
  description = "IP address of the backup LXC container."
  value       = local.container_ip
}
