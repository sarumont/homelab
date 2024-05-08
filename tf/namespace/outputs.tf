output "namespace" {
  value = kubernetes_namespace.ns.metadata.0.name
}
