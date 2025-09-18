variable "chart_name" {
  description = "Name of the Truecharts Helm chart"
}

variable "chart_version" {
  description = "Version of the Helm chart to use"
}

variable "namespace" {
  description = "Namespace to create for this release"
}

variable "release_name" {
  description = "Name for the Helm release"
}

variable "nfs_volumes" {
  description = "NFS volumes to mount"
  type = list(
    object({
      name   = string,
      server = string,
      path   = string,
    })
  )
}

variable "dnsimple_domain" {
  description = "Base domain under which to create DNSimple records"
  default = ""
}

variable "dnsimple_record_name" {
  description = "Name of the DNSimple domain name"
  default = ""
}

variable "dnsimple_record_target" {
  description = "Target to point domain names to"
  default = ""
}

variable "dnsimple_record_type" {
  description = "Type of DNS record to create"
  default = "CNAME"
}

variable "dnsimple_record_ttl" {
  description = "TTL for DNS record"
  default = 3600
}

variable "values" {
  description = "Raw YAML values to pass to the chart"
  type = list(string)
}
