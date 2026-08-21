variable "repository" {
  description = "Helm repository URL (HTTP/HTTPS or OCI)"
}

variable "chart_name" {
  description = "Name of the Helm chart"
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
  type        = list(string)
  # secrets get interpolated into this YAML directly by callers (e.g.
  # authelia's hmac_secret, mealie/karakeep's OIDC client_secret) before
  # terraform ever sees them - terraform has no way to know that unless
  # this variable is explicitly marked sensitive, so without this the
  # full computed YAML (secrets included) prints in plan/apply output.
  sensitive = true
}
