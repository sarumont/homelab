resource "kubernetes_manifest" "lb_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"      = "lb-pool"
      "namespace" = "metallb-system"
    }
    "spec" = {
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
      "name"      = "lb-pool-advertisement"
      "namespace" = "metallb-system"
    }
    "spec" = {
      "ipAddressPools" = [
        kubernetes_manifest.lb_pool.manifest.metadata.name
      ]
    }
  }
}
