variable "dnsimple_token" {
  description = "Token for DNSimple's API"
  sensitive = true
}

variable "account" {
  description = "Account ID to use for DNSimple"
}

variable "zone_id" {
  description = "Zone ID to update in DNSimple"
}

variable "record_id" {
  description = "Record ID to update in DNSimple"
}
