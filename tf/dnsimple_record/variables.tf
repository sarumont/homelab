variable "dnsimple_domain" {
  description = "Base domain under which to create DNSimple records"
}

variable "dnsimple_record_name" {
  description = "Name of the DNSimple domain name"
  default = "lms"
}

variable "dnsimple_record_target" {
  description = "Target to point domain names to"
}

variable "dnsimple_record_type" {
  description = "Type of DNS record to create"
  default = "CNAME"
}

variable "dnsimple_record_ttl" {
  description = "TTL for DNS record"
  default = 3600
}
