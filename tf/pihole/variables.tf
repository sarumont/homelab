variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the pihole Helm chart to use"
  default = "2.31.0"
}

variable "pihole_release_name" {
  description = "Release name to use for Pihole"
  default = "pihole"
}

variable "ip" {
  description = "IP address to assign to PiHole"
}

variable "storage_class" {
  description = "Storage class to use for the config PVC"
  default = "-"
}

variable "custom_dns_entries" {
  description = "Custom DNS entries to add to Pihole"
  type = list(string)
}

variable "custom_cname_entries" {
  description = "Custom CNAME entries to add to Pihole"
  type = list(string)
}

variable "unbound_chart_version" {
  description = "Version of the unbound Helm chart to use"
  default = "0.1.5"
}

variable "unbound_image_tag" {
  description = "The image tag to pull for the klutchell/unbound docker image"
  default = "1.23.0"
}

variable "unbound_ip" {
  description = "IP address to assign to Unbound DNS"
}

variable "unbound_additional_config" {
  description = "Additional configuration to provide to unbound.conf"
  default = ""
}
