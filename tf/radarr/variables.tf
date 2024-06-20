variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "namespace" {
  description = "Namespace to deploy in"
  default = "tortuga"
}

variable "chart_version" {
  description = "Version of the Radarr Helm chart to use"
  default = "23.1.1"
}

variable "cluster_domain" {
  description = "Domain name for the cluster"
}

variable "ingress_class" {
  description = "Ingress class name to use"
  default = "nginx"
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
