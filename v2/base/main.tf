resource "kubernetes_namespace" "metallb_ns" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = "metallb-system"
}
