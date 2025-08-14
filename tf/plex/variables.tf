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

variable "release_name" {
  description = "Release name for the Helm release"
  default = "plex"
}

variable "config_storage_class" {
  description = "Storage class to use for the config PVC"
  default = "local-path"
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
