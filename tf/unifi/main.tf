resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "unifi" {
  name = "unifi"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  chart = "unifi-controller"
  repository = "https://sarumont.github.io/homelab"
  version = var.chart_version

  values = [
<<EOT
image:
  registry: ${var.image_registry}
  repository: ${var.image_repository}
  tag: ${var.image_version}
environment:
  timezone: ${var.timezone}
service:
  loadBalancerIP: ${var.ip}
persistence:
  storageClass: "local-path"
  backup:
    storageClass: "local-path"
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 1
    memory: 3Gi
EOT
  ]
}
