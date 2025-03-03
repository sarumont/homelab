variable "nginx_chart_version" {
  description = "Version of the nginx Helm chart to use"
  default = "4.7.2"
}

variable "nfd_chart_version" {
  description = "Version of the nfd Helm chart to use"
  default = "0.13.1"
}

variable "cluster_domain" {
  description = "Domain to use for cluster DNS names"
}

variable "ingress_ip" {
  description = "IP address to request for the ingress controller"
}

variable "external_ingress_ip" {
  description = "IP address to request for the external ingress controller"
}

variable "lb_pool" {
  description = "IP address Pool to use for load balancer"
}

variable "dnsimple_token" {
  description = "DNSimple access token"
  sensitive = true
}

variable "dnsimple_account" {
  description = "DNSimple account ID"
}

variable "dnsimple_domain" {
  description = "Base domain under which to create DNSimple records"
}

variable "dnsimple_internal_ingress_record" {
  description = "Record name to create for the internal ingress's IP"
}

variable "dnsimple_record_ttl" {
  description = "TTL for DNS record"
  default = 3600
}

variable "issuer_email" {
  description = "Cluster issuer email"
}

variable "issuer_group_name" {
  description = "Group name to use for the DNSimple webhook issuer"
}
