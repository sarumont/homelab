variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable image_registry {
  description = "Unifi Controller image registry"
  default = "docker.io"
}

variable image_repository {
  description = "Unifi Controller image repository"
  default = "jacobalberty/unifi"
}

variable image_version {
  description = "Unifi Controller version"
  default = "v9.0.114"
}

variable chart_version {
  description = "Unifi Controller chart version"
  default = "1.1.0"
}

variable namespace {
  description = "Unifi Controller Namespace"
  default = "unifi"
}

variable ip {
  description = "IP to use for the Unifi Controller service"
}

variable storage_class {
  description = "Storage class to use for PVCs"
  default = "local-path"
}
