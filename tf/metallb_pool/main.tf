resource "kubernetes_manifest" "lb_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"       = var.name
      "namespace"  = var.namespace
    }
    "spec" = {
      "autoAssign" = var.autoassign
      "addresses" = [
        var.lb_pool
      ]
    }
  }
}

resource "kubernetes_manifest" "lb_advertisement" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "L2Advertisement"
    "metadata" = {
      "name"       = "${var.name}-advertisement"
      "namespace"  = var.namespace
    }
    "spec" = {
      "ipAddressPools" = [
        kubernetes_manifest.lb_pool.manifest.metadata.name
      ]
    }
  }
}
