provider "helm" {
  kubernetes {
      config_path = "~/.kube/config"
  }
}

resource "helm_release" "plex" {
  name       = "plex"
  repository = "https://charts.saturnwire.com"
  chart      = "plex"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
<<EOT
replicaCount: ${var.replica_count}
image:
  tag: ${var.plex_image_tag}
EOT
  ]
}
