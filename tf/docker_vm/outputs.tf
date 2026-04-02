output "vm_ip" {
  description = "Primary IP address of the VM (first NIC, without CIDR)."
  value       = local.primary_ip
}
