variable "monitors" {
  description = "Map of push monitor definitions (name → interval in seconds)."
  type        = map(number)
}

variable "uptime_kuma_base_url" {
  description = "Base URL of Uptime Kuma instance (e.g. http://uptime-kuma.homelab.sigil.org)."
  type        = string
}
