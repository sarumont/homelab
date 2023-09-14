variable "nginx_chart_version" {
  description = "Version of the nginx Helm chart to use"
  default = "4.7.2"
}

variable "cluster_domain" {
  description = "Domain to use for cluster DNS names"
}

variable "nfs_server" {
  description = "NFS server to use for persistent storage"
}

variable "nfs_path" {
  description = "Path on NFS server to use for persistent storage"
}

variable "ingress_ip" {
  description = "IP address to request for the ingress"
}

variable "lb_pool" {
  description = "IP address Pool to use for load balancer"
}
