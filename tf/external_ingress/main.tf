resource "dnsimple_zone_record" "dns_record" {
  count = var.dnsimple_domain == "" ? 0 : 1

  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_v1" "external" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  spec {
    type          = "ExternalName"
    external_name = var.backend_host

    port {
      port        = var.backend_port
      target_port = var.backend_port
    }
  }
}

resource "kubernetes_ingress_v1" "external" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.ns.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"                = var.cluster_issuer
      "nginx.ingress.kubernetes.io/service-upstream"  = "true"
    }
  }

  spec {
    ingress_class_name = var.ingress_class_name

    tls {
      hosts       = [var.host]
      secret_name = var.tls_secret_name
    }

    rule {
      host = var.host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.external.metadata.0.name

              port {
                number = var.backend_port
              }
            }
          }
        }
      }
    }
  }
}
