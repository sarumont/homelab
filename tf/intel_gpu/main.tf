resource "kubernetes_namespace" "intel_gpu_ns" {
  metadata {
    name = "intel-gpu"
  }
}

resource "helm_release" "intel_device_plugins_operator" {
  name       = "intel-device-plugins-operator"
  repository = "https://intel.github.io/helm-charts/"
  chart      = "intel-device-plugins-operator"
  version    = var.operator_chart_version
  namespace  = kubernetes_namespace.intel_gpu_ns.metadata.0.name
}

resource "helm_release" "intel_device_plugins_gpu" {
  name       = "intel-device-plugins-gpu"
  repository = "https://intel.github.io/helm-charts/"
  chart      = "intel-device-plugins-gpu"
  version    = var.device_plugins_chart_version
  namespace  = kubernetes_namespace.intel_gpu_ns.metadata.0.name

  set {
    name = "nodeFeatureRule"
    value = true
  }
}
