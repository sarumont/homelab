resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "plex" {
  name       = var.release_name
  repository = "oci://tccr.io/truecharts"
  chart      = "plex"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name

  set = concat(
    [for idx, val in var.nfs_volumes : {
      name  = "persistence.${val.name}.enabled"
      value = true
    }],

    [for idx, val in var.nfs_volumes : {
      name  = "persistence.${val.name}.type"
      value = "nfs"
    }],

    [for idx, val in var.nfs_volumes : {
      name  = "persistence.${val.name}.mountPath"
      value = "/media/${val.name}"
    }],

    [for idx, val in var.nfs_volumes : {
      name  = "persistence.${val.name}.path"
      value = "${val.path}"
    }],

    [for idx, val in var.nfs_volumes : {
      name  = "persistence.${val.name}.server"
      value = "${val.server}"
    }]
  )

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
persistence:
  config:
    storageClass: ${var.config_storage_class}
EOT
  ]
}

resource "kubernetes_service" "plex_nodeport" {
  metadata {
    name = "plex-nodeport"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }
  spec {
    selector = {
      "app.kubernetes.io/instance" = "plex"
      "app.kubernetes.io/name"="plex"
      "pod.name"="main"
    }
    type = "NodePort"
    port {
      node_port   = 32400
      port        = 32400
      target_port = 32400
    }
  }
}
