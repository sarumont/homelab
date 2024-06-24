variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the sonarr Helm chart to use"
  default = "23.1.1"
}

variable "cluster_domain" {
  description = "Domain name for the cluster"
}

variable "ingress_class" {
  description = "Ingress class name to use"
  default = "nginx"
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
}

variable "dnsimple_record_name" {
  description = "Name of the DNSimple domain name"
  default = "sonarr"
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
