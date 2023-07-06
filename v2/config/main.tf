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
        "172.21.1.30-172.21.1.40"
      ]
    }
  }
}
