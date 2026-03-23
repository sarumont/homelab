variable "backups" {
  description = "Map of database backup definitions"
  type = map(object({
    namespace           = string
    schedule            = optional(string, "0 2 * * *")
    db_type             = string
    db_host             = string
    db_port             = optional(number, 5432)
    secret_name         = string
    db_user             = optional(string, null)
    secret_username_key = optional(string, "username")
    secret_password_key = optional(string, "password")
    push_url            = optional(string, "")
  }))

  validation {
    condition     = alltrue([for k, v in var.backups : contains(["postgres", "mariadb"], v.db_type)])
    error_message = "db_type must be \"postgres\" or \"mariadb\"."
  }
}

variable "nfs_server" {
  description = "NFS server IP"
}

variable "nfs_path" {
  description = "NFS base path for backups"
}

variable "retention_days" {
  description = "Number of days to retain backups"
  default     = 7
  type        = number
}
