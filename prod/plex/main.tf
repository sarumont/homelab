resource "helm_release" "plex" {
  name       = "plex"
  repository = "../../../plex-helm-chart" #"https://charts.saturnwire.com"
  chart      = "chart"

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
service:
  type: NodePort
  port: 32400
image:
  tag: ${var.plex_image_tag}
ingress:
  enabled: true
volumeMounts:
- name: tv
  mountPath: /mnt/tv
- name: movies
  mountPath: /mnt/movies
- name: music
  mountPath: /mnt/music
volumes:
- name: tv
  hostPath:
    path: ${var.plex_tv_path}
- name: movies
  hostPath:
    path: ${var.plex_movies_path}
- name: music
  hostPath:
    path: ${var.plex_music_path}
plex:
  timezone: ${var.timezone}
  hostname: ${var.plex_hostname}
EOT
  ]
}
