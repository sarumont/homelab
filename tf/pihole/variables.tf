variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the pihole Helm chart to use"
  default = "2.18.0"
}

variable "image_version" {
  description = "Version of the Pihole docker images to use"
  default = "2024.07.0"
}

variable "ip" {
  description = "IP address to assign to PiHole"
}

variable "custom_dns_entries" {
  description = "Custom DNS entries to add to Pihole"
  type = list(string)
}

variable "custom_cname_entries" {
  description = "Custom CNAME entries to add to Pihole"
  type = list(string)
}
