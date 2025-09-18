resource "random_password" "admin_password" {
  length           = 16
  special          = false
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "postgres" {
  name       = var.release_name
  namespace  = kubernetes_namespace.ns.metadata.0.name
  chart      = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  version    = var.chart_version

  values = [
<<EOT
defaultStorageClass: ${var.storage_class}

image:
  registry: ${var.image_registry}
  repository: ${var.image_repository}
  tag: ${var.image_version}

auth:
  username: admin
  password: ${random_password.admin_password.result}

primary:
  service:
    type: ${var.service_type}
    # used for NodePort, ignored for others
    nodePorts:
      postgres:
        35432
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
