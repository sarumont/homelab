resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cnpg" {
  name       = var.release_name
  namespace  = kubernetes_namespace.ns.metadata.0.name
  chart      = "cloudnative-pg"
  repository = "https://cloudnative-pg.github.io/charts"
  version    = var.chart_version
}
