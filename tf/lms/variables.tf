variable "namespace" {
  description = "Namespace to deploy in"
  default = "lms"
}

variable "hostname" {
  description = "Hostname to use"
  default = "lms"
}

variable "chart_version" {
  description = "Version of the LMS Helm chart to use"
  default = "13.1.4"
}

variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
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
      prefix = string,
    })
  )
}

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
