resource "helm_release" "postgres" {
  name = "postgres"
  namespace = "shared"
  chart = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  version = var.postgresql_chart_version
  create_namespace = true

  values = [
<<EOT
image:
  registry: ${var.postgresql_registry}
  repository: ${var.postgresql_repository}
  tag: ${var.postgresql_version}
auth:
  postgresPassword: ${var.postgresql_password}
  password: ${var.postgresql_password}
postgresqlDataDir: ${var.postgresql_data_dir}

primary:
  podSecurityContext:
    fsGroup: ${var.postgresql_gid}
  containerSecurityContext:
    runAsUser: ${var.postgresql_uid}
  service:
    type: NodePort
    nodePorts:
      postgresql:
        32432
  persistence:
    mountPath: ${var.postgresql_mount_path}
    subPath: ${var.postgresql_sub_path}
EOT
  ]
}

