variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the Plex Helm chart to use"
  default = "2.1.1"
}

variable "image_version" {
  description = "Version of the Plex docker image use"
  default = "1.32.6.7468-07e0d4a7e"
}

variable "access_mode" {
  description = "Access mode for the NFS share (see Kubernetes PersistentVolume)"
  type    = string
  default = "ReadWriteMany"

  validation {
    condition     = contains(["ReadWriteMany", "ReadOnlyMany", "ReadWriteOnce"], var.access_mode)
    error_message = "Allowed values for access_mode are \"ReadWriteMany\", \"ReadOnlyMany\", or \"ReadWriteOnce\"."
  }
}

variable "namespace" {
  description = "Namespace to deploy in"
  default = "plex"
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
