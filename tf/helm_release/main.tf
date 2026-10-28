resource "dnsimple_zone_record" "dns_record" {
  count = var.dnsimple_domain == "" ? 0 : 1

  zone_name = var.dnsimple_domain
  name      = var.dnsimple_record_name
  value     = var.dnsimple_record_target
  type      = var.dnsimple_record_type
  ttl       = var.dnsimple_record_ttl
}

resource "helm_release" "helm_chart" {
  name             = var.release_name
  repository       = var.repository
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  cleanup_on_fail  = true

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

  lifecycle {
    # helm_release's computed `metadata` block echoes back the fully
    # rendered chart values (secrets included) and is not marked
    # sensitive by the provider schema - marking var.values sensitive
    # does nothing for it. Unresolved upstream:
    # https://github.com/hashicorp/terraform-provider-helm/issues/424
    # https://github.com/hashicorp/terraform-provider-helm/issues/485
    # metadata is read-only/computed, so ignoring it doesn't affect
    # what gets applied - it just stops terraform from diffing (and
    # printing) it on every plan.
    ignore_changes = [metadata]
  }
}
