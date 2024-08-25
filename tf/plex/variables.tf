variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the Plex Helm chart to use"
  default = "19.1.6"
}

variable "namespace" {
  description = "Namespace to deploy in"
  default = "plex"
}

variable "ip" {
  description = "IP address to assign to Plex"
}

variable "nfs_volumes" {
  description = "NFS volumes to mount"
  type = list(
    object({
      name   = string,
      server = string,
      path   = string,
    })
  )
}
