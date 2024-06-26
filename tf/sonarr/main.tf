resource "kubernetes_namespace" "ns" {
  metadata {
    name = "sonarr"
  }
}

# Add a record to a sub-domain
resource "dnsimple_zone_record" "sonarr_cname" {
  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "helm_release" "sonarr" {
  name       = "sonarr"
  repository = "oci://tccr.io/truecharts"
  chart      = "sonarr"
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
ingress:
  sonarr:
    enabled: true
    primary: true
    required: true
    ingressClassName: ${var.ingress_class}
    hosts:
      - host: sonarr.${var.cluster_domain}
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
EOT
  ]
}
