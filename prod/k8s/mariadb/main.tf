resource "random_password" "root_password" {
  length           = 16
  special          = false
}

resource "helm_release" "mariadb" {
  name = "mariadb"
  namespace = "shared"
  chart = "mariadb"
  repository = "https://charts.bitnami.com/bitnami"
  version = var.mariadb_chart_version
  create_namespace = true

  values = [
<<EOT
image:
  registry: ${var.mariadb_registry}
  repository: ${var.mariadb_repository}
  tag: ${var.mariadb_version}
auth:
  rootPassword: ${random_password.root_password.result}
primary:
  service:
    type: NodePort
    nodePorts:
      mysql:
        32306
EOT
  ]
}
