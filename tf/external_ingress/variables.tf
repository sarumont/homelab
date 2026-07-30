variable "namespace" {
  description = "Namespace to create for the ingress/service objects"
}

variable "name" {
  description = "Name to use for the Service and Ingress objects"
}

variable "backend_host" {
  description = "Hostname of the external (non-cluster) backend to proxy to"
}

variable "backend_port" {
  description = "Port of the external backend to proxy to"
}

variable "host" {
  description = "External hostname to serve the ingress on"
}

variable "ingress_class_name" {
  description = "IngressClass to use"
  default     = "nginx-external"
}

variable "cluster_issuer" {
  description = "cert-manager ClusterIssuer to request the TLS cert from"
  default     = "cert-manager-webhook-dnsimple-production"
}

variable "tls_secret_name" {
  description = "Name of the Secret cert-manager will store the issued certificate in"
}

variable "dnsimple_domain" {
  description = "Base domain under which to create the DNSimple record. Leave empty to skip DNS record creation."
  default     = ""
}

variable "dnsimple_record_name" {
  description = "Name of the DNSimple record"
  default     = ""
}

variable "dnsimple_record_target" {
  description = "Target to point the DNS record to"
  default     = ""
}

variable "dnsimple_record_type" {
  description = "Type of DNS record to create"
  default     = "CNAME"
}

variable "dnsimple_record_ttl" {
  description = "TTL for the DNS record"
  default     = 3600
}
