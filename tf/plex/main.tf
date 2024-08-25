resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "plex" {
  name       = "plex"
  repository = "oci://tccr.io/truecharts"
  chart      = "plex"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name

  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "persistence.${set.value.name}.enabled"
      value = true
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "persistence.${set.value.name}.type"
      value = "nfs"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "persistence.${set.value.name}.mountPath"
      value = "/media/${set.value.name}"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "persistence.${set.value.name}.path"
      value = "${set.value.path}"
    }
  }
  dynamic "set" {
    for_each = {for idx, val in var.nfs_volumes: idx => val}
    content {
      name  = "persistence.${set.value.name}.server"
      value = "${set.value.server}"
    }
  }

  values = [
<<EOT
plex:
  serverIP: ${var.ip}
service:
  main:
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
