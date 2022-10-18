variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable postgresql_registry {
  description = "PostgreSQL image registry"
  default = "docker.io"
}

variable postgresql_repository {
  description = "PostgreSQL image repository"
  default = "bitnami/postgresql"
}

variable postgresql_version {
  description = "PostgreSQL version"
  default = "14"
}

variable postgresql_chart_version {
  description = "PostgreSQL chart version"
  default = "11.9.8"
}

variable postgresql_password {
  description = "Password to use for postgres user"
  default = "postgres"
}

variable postgresql_data_dir {
  description = "PostgreSQL data directory"
  default = "/bitnami/postgresql/data"
}

variable postgresql_mount_path {
  description = "Mount path for the persistent volume"
  default = "/bitnami/postgresql"
}

variable postgresql_sub_path {
  description = "Subpath to use under the mount path for data storage"
  default = ""
}

variable postgresql_uid {
  description = "User ID to launch Postgres as"
  default = "1001"
}

variable postgresql_gid {
  description = "Group ID to launch Postgres as"
  default = "1001"
}
