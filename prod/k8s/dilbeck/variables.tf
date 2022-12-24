variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable "photoprism_image_tag" {
  description = "Version of Photoprism to run"
  default = "221118-jammy"
  type = string
}

variable "domains" {
  description = "Base domains to configure"
  type = list(string)
}

variable "dilbeck_photoprism_site_url" {
  description = "URL for public access to Photoprism"
  default = "http://photoprism.me:2342"
}

variable "dilbeck_photoprism_storage_path" {
  description = "Path to mount for Photoprism storage"
}

variable "dilbeck_photoprism_originals_path" {
  description = "Path to mount for Photoprism originals storage"
}

variable "dilbeck_photoprism_imports_path" {
  description = "Path to mount for Photoprism imports"
}

variable "db_root_password" {
  description = "Root password to the database"
}
