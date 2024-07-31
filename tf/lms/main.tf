# Add a record to a sub-domain
resource "dnsimple_zone_record" "lms_cname" {
  create_if = var.dnsimple_domain != null

  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "helm_release" "lms" {
  name       = "logitech-media-server"
  repository = "oci://tccr.io/truecharts"
  chart      = "logitech-media-server"
  version    = var.chart_version
  namespace  = var.namespace
  create_namespace = true

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
      value = "${set.value.prefix}/${set.value.name}"
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
image:
  pullPolicy: always
ingress:
  lms:
    enabled: true
    primary: true
    required: true
    ingressClassName: ${var.ingress_class}
    hosts:
      - host: ${var.hostname}.${var.cluster_domain}
        paths:
          - path: "/"

    %{ if var.dnsimple_record_name} != null }
      - host: ${var.dnsimple_record_name}.${var.dnsimple_domain}
        paths:
          - path: "/"
    %{ endif }

    integrations:
      traefik:
        enabled: false
EOT
  ]
}
