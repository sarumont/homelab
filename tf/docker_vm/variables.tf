variable "proxmox_node" {
  description = "Target Proxmox node for the VM."
  type        = string
}

variable "hostname" {
  description = "VM hostname."
  type        = string
}

variable "template" {
  description = "Cloud-init template name to clone."
  type        = string
}

variable "storage_id" {
  description = "Storage ID for the VM disk."
  type        = string
  default     = "local-lvm"
}

variable "cloudinit_storage_id" {
  description = "Storage ID for the cloud-init drive."
  type        = string
}

variable "disk_size" {
  description = "OS disk size (e.g. 32G)."
  type        = string
  default     = "32G"
}

variable "cores" {
  description = "Number of vCPUs."
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM in MB."
  type        = number
  default     = 2048
}

variable "user" {
  description = "Cloud-init user."
  type        = string
  default     = "ubuntu"
}

variable "networks" {
  description = "Network interfaces: bridge, tag (0 = untagged), ip (CIDR), gateway (optional)."
  type = list(object({
    bridge  = string
    tag     = optional(number, 0)
    ip      = string
    gateway = optional(string, "")
  }))
}

variable "nameserver" {
  description = "DNS server IP."
  type        = string
}

variable "authorized_keys_file" {
  description = "Path to file containing public SSH keys."
  type        = string
}

variable "timezone" {
  description = "Timezone for the VM (e.g. America/Denver)."
  type        = string
  default     = "UTC"
}

variable "nfs_mounts" {
  description = "NFS shares to mount inside the VM."
  type = list(object({
    server      = string
    path        = string
    mount_point = string
  }))
  default = []
}

variable "directories" {
  description = "Paths to mkdir -p after NFS mounts are ready."
  type        = list(string)
  default     = []
}

variable "sysctl_settings" {
  description = "Custom sysctl key-value pairs."
  type        = map(string)
  default     = {}
}

variable "docker_compose_content" {
  description = "Full docker-compose.yml content to deploy."
  type        = string
}

variable "env_vars" {
  description = "Environment variables written to /opt/docker/.env."
  type        = map(string)
  default     = {}
  sensitive   = true
}
