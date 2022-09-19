variable "replica_count" {
  description = "Number of pods to run"
  default = 1
  type = number
}

varibale "plex_image_tag" {
  description = "Version of Plex to run"
  default = "1.28.2.6151-914ddd2b3"
}
