data "kubernetes_service" "svc" {
  metadata {
    name = var.svc_name
    namespace = var.namespace
  }
}

output "lb_ip_addr" {
  value = data.kubernetes_service.svc.status.0.load_balancer.0.ingress.0.ip
  description = "The IP of the LoadBalancer service"
}
