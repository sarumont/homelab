variable "proxmox_node" {
  description = "Target Proxmox node for the LXC container."
  type        = string
}

variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g. https://192.168.1.15:8006/api2/json)."
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox user for API auth."
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox password for API auth."
  type        = string
  sensitive   = true
}

variable "hostname" {
  description = "Hostname for the LXC container."
  type        = string
}

variable "ostemplate" {
  description = "LXC template path (e.g. local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst)."
  type        = string
}

variable "storage_id" {
  description = "Storage ID for the container rootfs."
  type        = string
  default     = "local-lvm"
}

variable "disk_size" {
  description = "Rootfs disk size."
  type        = string
  default     = "4G"
}

variable "cores" {
  description = "Number of CPU cores."
  type        = number
  default     = 1
}

variable "memory" {
  description = "Memory in MB."
  type        = number
  default     = 256
}

variable "ip_address" {
  description = "Static IP in CIDR notation (e.g. 172.21.1.50/24)."
  type        = string
}

variable "gateway" {
  description = "Network gateway IP."
  type        = string
}

variable "nameserver" {
  description = "DNS server IP."
  type        = string
}

variable "network_bridge" {
  description = "Proxmox network bridge."
  type        = string
  default     = "vmbr0"
}

variable "authorized_keys_file" {
  description = "Path to file containing public SSH keys for root access."
  type        = string
}

variable "timezone" {
  description = "Timezone for the container (e.g. America/Denver)."
  type        = string
  default     = "UTC"
}

variable "nfs_mounts" {
  description = "NFS shares to mount inside the container."
  type = list(object({
    server      = string
    path        = string
    mount_point = string
  }))
}

variable "static_routes" {
  description = "Static routes to add inside the container."
  type = list(object({
    destination = string
    gateway     = string
  }))
  default = []
}

variable "rsync_jobs" {
  description = "Rsync backup job definitions."
  type = list(object({
    name             = string
    source           = string
    destination      = string
    flags            = string
    schedule         = string
    exclude_patterns = optional(list(string), [])
    push_url         = optional(string, "")
  }))
}
