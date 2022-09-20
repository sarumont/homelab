variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

variable "plex_image_tag" {
  description = "Version of Plex to run"
  default = "1.28.2.6151-914ddd2b3"
}

variable "plex_hostname" {
  description = "The name to pass to Plex for the server's hostname"
  default = "plex"
}

variable "timezone" {
  description = "The timezone to pass through to Plex"
  default = "UTC"
}

variable "domains" {
  description = "Base domains to configure"
  type = list(string)
}
