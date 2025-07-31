resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

# Add a record to a sub-domain
resource "dnsimple_zone_record" "radarr_cname" {
  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "helm_release" "radarr" {
  name       = var.release_name
  repository = "oci://tccr.io/truecharts"
  chart      = "radarr"
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
ingress:
  radarr:
    enabled: true
    primary: true
    required: true
    ingressClassName: ${var.ingress_class}
    hosts:
      - host: ${var.release_name}.${var.cluster_domain}
        paths:
          - path: "/"
      - host: ${var.dnsimple_record_name}.${var.dnsimple_domain}
        paths:
          - path: "/"
    integrations:
      traefik:
        enabled: false

metrics:
  main:
    enabled: false
service:
  metrics:
    enabled: false

workload:
  exportarr:
    enabled: false

persistence:
  config:
    storageClass: ${var.storage_class}

EOT
  ]
}
