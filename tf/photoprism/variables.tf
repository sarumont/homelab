variable "timezone" {
  description = "Timezone to use for various services"
  default = "America/Denver"
}

variable "chart_version" {
  description = "Version of the Photoprism Helm chart to use"
  default = "0.2.1"
}

variable "image_version" {
  description = "Version of the Photoprism docker image use"
  default = "231021"
}

variable "ingress_hosts" {
  description = "Hostnames to configure for ingress matching"
  type = list(string)
}

variable "tls_host" {
  description = "Hostname to configure TLS certs for"
  type = string
}

variable "ingress_class_name" {
  description = "Class name of the Ingress to configure"
  default = "default"
}

variable "site_url" {
  description = "URL for public access to Photoprism"
  default = "http://photoprism.me:2342"
}

variable "nfs_server" {
  description = "NFS server to use for image storage"
}

variable "storage_path" {
  description = "Path to mount for Photoprism storage"
}

variable "originals_path" {
  description = "Path to mount for Photoprism originals storage"
}

variable "imports_path" {
  description = "Path to mount for Photoprism imports"
}

variable "autoimport_delay" {
  description = "Delay before automatically importing uploads. -1 disables."
  default = "-1"
}

variable "namespace" {
  description = "Namespace to deploy in"
  default = "photoprism"
}

variable "provider_db_addr" {
  description = "Address to connect to the MySQL DB for the provider"
}

variable "db_root_password" {
  description = "Root password to the database for provisioning a new DB"
}

variable "db_addr" {
  description = "Address to connect to the MySQL DB for the service"
}

variable "db_name" {
  description = "Name of the DB to create for this instance of Photoprism"
  default = "photoprism"
}

variable "db_user" {
  description = "Name of the DB user to create for this instance of Photoprism"
  default = "photoprism"
}

variable "dnsimple_domain" {
  description = "Base domain under which to create DNSimple records"
}

variable "dnsimple_record_name" {
  description = "Name of the DNSimple domain name"
  default = "photos"
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
