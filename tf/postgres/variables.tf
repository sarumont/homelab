variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable storage_class {
  description = "Storage class to use"
  default = "local-path"
}

variable image_registry {
  description = "Postgres image registry"
  default = "docker.io"
}

variable image_repository {
  description = "Postgres image repository"
  default = "bitnami/postgresql"
}

variable image_version {
  description = "Postgres version"
  default = "17.6.0"
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
  description = "Postgres chart version"
  default = "16.7.27"
}

variable namespace {
  description = "Namespace"
  default = "postgres"
}

variable release_name {
  description = "Helm Release Name"
  default = "postgres"
}

