resource "helm_release" "photoprism" {
  name       = "photoprism"
  repository = "../../../../" # https://p80n.github.io/photoprism-helm/"
  chart      = "photoprism-helm" #"photoprism"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.port"
    value = "2342"
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}].host"
      value = "photos.${set.value}"
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
  tag: ${var.photoprism_image_tag}
config:
  PHOTOPRISM_DEBUG: true
  PHOTOPRISM_READONLY: false
  PHOTOPRISM_PUBLIC: true
ingress:
  enabled: true
  tls: []
persistence:
  enabled: true
  storagePath:   &storagePath    /photoprism/storage
  originalsPath: &originalsPath  /photoprism/originals
  importPath:    &importPath     /photoprism/import
  volumeMounts:
  - name: originals
    mountPath: *originalsPath
  - name: storage
    mountPath: *storagePath
  - name: imports
    mountPath: *importPath
  volumes:
  - name: originals
    hostPath:
      path: ${var.photoprism_originals_path}
  - name: storage
    hostPath:
      path: ${var.photoprism_storage_path}
  - name: imports
    hostPath:
      path: ${var.photoprism_imports_path}
EOT
  ]
}
