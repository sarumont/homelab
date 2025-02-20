resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "unifi" {
  name       = "unifi"
  repository = "oci://tccr.io/truecharts"
  chart      = "unifi"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name

  values = [
<<EOT
service:
  main:
    enabled: true
    primary: true
    type: LoadBalancer
    loadBalancerIP: ${var.ip}
    annotations:
      metallb.universe.tf/allow-shared-ip: unifi
  comm:
    enabled: true
    type: LoadBalancer
    loadBalancerIP: ${var.ip}
    annotations:
      metallb.universe.tf/allow-shared-ip: unifi
  stun:
    enabled: true
    type: LoadBalancer
    loadBalancerIP: ${var.ip}
    annotations:
      metallb.universe.tf/allow-shared-ip: unifi
EOT
  ]
}
