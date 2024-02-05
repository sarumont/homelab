output "mariadb_root_password" {
  value = random_password.root_password.result
  sensitive = true
}

data "kubernetes_service" "svc" {
  metadata {
    name = "mariadb"
    namespace  = kubernetes_namespace.ns.metadata.0.name
  }
}

output "lb_ip_addr" {
  value = data.kubernetes_service.svc.status.0.load_balancer.0.ingress.0.ip
}
