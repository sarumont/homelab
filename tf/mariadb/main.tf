resource "random_password" "root_password" {
  length           = 16
  special          = false
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "mariadb" {
  name = "mariadb"
  namespace  = kubernetes_namespace.ns.metadata.0.name
  chart = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  version = var.chart_version

  values = [
<<EOT
image:
  registry: ${var.image_registry}
  repository: ${var.image_repository}
  tag: ${var.image_version}
auth:
  rootPassword: ${random_password.root_password.result}
primary:
  service:
    type: ${var.service_type}
    # used for NodePort, ignored for others
    nodePorts:
      mysql:
        32306
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 2
      memory: 3Gi
EOT
  ]
}
