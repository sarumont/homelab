resource "helm_release" "plex" {
  name       = "plex"
  repository = "../../../plex-helm-chart" #"https://charts.saturnwire.com"
  chart      = "chart"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}].host"
      value = "plex.${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}].paths[0]"
      value = "/"
    }
  }

  values = [
<<EOT
replicaCount: ${var.replica_count}
image:
  tag: ${var.plex_image_tag}
ingress:
  enabled: true
plex:
  timezone: ${var.timezone}
  hostname: ${var.plex_hostname}
EOT
  ]
}
