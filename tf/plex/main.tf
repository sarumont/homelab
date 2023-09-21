resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "plex" {
  name       = "plex"
  repository = "https://utkuozdemir.org/helm-charts"
  chart      = "plex"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name

  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "extraVolumes[${set.key}].name"
      value = "${set.value.name}"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "extraVolumes[${set.key}].nfs.server"
      value = "${set.value.server}"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "extraVolumes[${set.key}].nfs.path"
      value = "${set.value.path}"
    }
  }

  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "extraVolumeMounts[${set.key}].name"
      value = "${set.value.name}"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "extraVolumeMounts[${set.key}].mountPath"
      value = "/media/${set.value.name}"
    }
  }

  values = [
<<EOT
env: 
  TZ: ${var.timezone}
  ADVERTISE_IP: ${var.ip}
image:
  repository: docker.io/plexinc/pms-docker
  tag: ${var.image_version}
ingress:
  enabled: false
service:
  type: LoadBalancer
  loadBalancerIP: ${var.ip}
resources: 
    requests: 
        gpu.intel.com/i915: "1" 
    limits: 
        gpu.intel.com/i915: "1" 
EOT
  ]
}
