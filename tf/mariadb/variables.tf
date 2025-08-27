variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable image_registry {
  description = "MariaDB image registry"
  default = "docker.io"
}

variable image_repository {
  description = "MariaDB image repository"
  default = "bitnami/mariadb"
}

variable image_version {
  description = "MariaDB version"
  default = "10.10.6"
}

variable service_type {
  description = "Type of service to use"
  default = "ClusterIP"

  validation {
    condition     = contains(["ClusterIP", "NodePort", "LoadBalancer"], var.service_type)
    error_message = "Allowed values for service_type are \"ClusterIP\", \"NodePort\", or \"LoadBalancer\"."
  }
}

variable chart_version {
  description = "MariaDB chart version"
  default = "13.1.3"
}

variable namespace {
  description = "MariaDB Namespace"
  default = "mariadb"
}

variable release_name {
  description = "MariaDB Helm Release Name"
  default = "mariadb"
}

variable storage_class {
  description = "Storage class to use"
  default = "local-path"
}
