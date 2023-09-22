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

variable chart_version {
  description = "MariaDB chart version"
  default = "13.1.3"
}

variable namespace {
  description = "MariaDB Namespace"
  default = "mariadb"
}
