variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable mariadb_registry {
  description = "MariaDB image registry"
  default = "docker.io"
}

variable mariadb_repository {
  description = "MariaDB image repository"
  default = "bitnami/mariadb"
}

variable mariadb_version {
  description = "MariaDB version"
  default = "10.6.10-debian-11-r6"
}

variable mariadb_chart_version {
  description = "MariaDB chart version"
  default = "11.3.3"
}
