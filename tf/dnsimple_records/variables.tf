
variable "dnsimple_records" {
  description = "All the DNSimple records to be managed by this module"
  type = list(object({
    domain = string,
    name   = string,
    target = string,
    type   = optional(string, "CNAME"),
    ttl    = optional(number, 3600),
  }))
  
}
