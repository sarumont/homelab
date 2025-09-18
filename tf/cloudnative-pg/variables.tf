variable storage_class {
  description = "Storage class to use"
  default = "local-path"
}

variable chart_version {
  description = "Cloudnative PG chart version"
  default = "1.0.11"
}

variable namespace {
  description = "Namespace"
  default = "cnpg"
}

variable release_name {
  description = "Helm Release Name"
  default = "cnpg"
}

