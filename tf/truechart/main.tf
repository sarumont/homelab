resource "dnsimple_zone_record" "dns_record" {
  count = var.dnsimple_domain == "" ? 0 : 1

  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "helm_release" "helm_chart" {
  name             = var.release_name
  repository       = "oci://tccr.io/truecharts"
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

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

  values = var.values
}
