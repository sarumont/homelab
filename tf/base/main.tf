# MetalLB
resource "kubernetes_manifest" "lb_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"      = "lb-pool"
      "namespace"  = "metallb-system" # this is hardcoded in the metallb module for the moment
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
      "namespace"  = "metallb-system"
    }
    "spec" = {
      "ipAddressPools" = [
        kubernetes_manifest.lb_pool.manifest.metadata.name
      ]
    }
  }
}

# Nginx ingress
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_chart_version
  namespace  = kubernetes_namespace.ingress_nginx.metadata.0.name

  values = [
<<EOT
controller:
  service:
    enableHttps: false
    internal:
      loadBalancerIP: ${var.ingress_ip}
EOT
  ]
}

# Create a record for the internal ingress controller
resource "dnsimple_zone_record" "ingress" {
  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_internal_ingress_record}"
  value     = "${var.ingress_ip}"
  type      = "A"
  ttl       = "${var.dnsimple_record_ttl}"
}

# Nginx ingress -- external traffic
resource "kubernetes_namespace" "ingress_nginx_external" {
  metadata {
    name = "ingress-nginx-external"
  }
}

resource "helm_release" "ingress_nginx_external" {
  name       = "ingress-nginx-external"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.nginx_chart_version
  namespace  = kubernetes_namespace.ingress_nginx_external.metadata.0.name

  values = [
<<EOT
controller:
  service:
    enableHttps: true
    internal:
      loadBalancerIP: ${var.external_ingress_ip}
  ingressClassResource:
    name: nginx-external
    controllerValue: k8s.io/ingress-nginx-external
  ingressClass: nginx-external
EOT
  ]
}

# hello world app
resource "helm_release" "hello_world" {
  name       = "hello-world"
  repository = "https://cloudecho.github.io/charts/"
  chart      = "hello"
  version    = var.hello_world_chart_version
  namespace  = "default"

  set = concat(
    [
      {
        name = "ingress.enabled"
        value = false
      },
    ]
  )
}

resource "kubernetes_ingress_v1" "hello_world_ingress" {
  metadata {
    name = "hello-world-ingress"
  }
  wait_for_load_balancer = true

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "hello.${var.cluster_domain}"
      http {
        path {
          backend {
            service {
              name = "hello-world"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}

# cert-manager
module "cert_manager" {
  source                = "terraform-iaac/cert-manager/kubernetes"
  chart_version         = var.cert_manager_chart_version
  cluster_issuer_email  = var.issuer_email
  # Created directly below instead, via the kubectl provider we already
  # have configured - the module's own cluster_issuer/certificates
  # resources need a second kubectl fork (alekc/kubectl) passed through
  # providers = {}, which hits a real terraform bug (non-HashiCorp
  # provider passthrough reports a false "Provider type mismatch" -
  # confirmed with correct, verified config on every side; not fixable
  # by renaming the local name).
  cluster_issuer_create = false
}

resource "kubectl_manifest" "cert_manager_cluster_issuer" {
  validate_schema = false

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "cert-manager"
    }
    spec = {
      acme = {
        server         = "https://acme-v02.api.letsencrypt.org/directory"
        preferredChain = "ISRG Root X1"
        email          = var.issuer_email
        privateKeySecretRef = {
          name = "cert-manager-private-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          },
        ]
      }
    }
  })

  depends_on = [module.cert_manager]
}

resource "helm_release" "cert-manager-dnsimple" {
  name       = "cert-manager-webhook-dnsimple"
  repository = "https://puzzle.github.io/cert-manager-webhook-dnsimple"
  chart      = "cert-manager-webhook-dnsimple"
  version    = var.dnsimple_webhook_chart_version
  namespace  = "cert-manager"
  depends_on = [module.cert_manager]

  values = [
<<EOT
groupName: ${var.issuer_group_name}
dnsimple:
  token: ${var.dnsimple_token}
  accountID: ${var.dnsimple_account}
clusterIssuer:
  email: ${var.issuer_email}
  production:
    enabled: true
  staging:
    enabled: true
EOT
  ]
}

# NFD
resource "kubernetes_namespace" "nfd_ns" {
  metadata {
    name = "node-feature-discovery"
  }
}

resource "helm_release" "nfd" {
  name       = "node-feature-discovery"
  repository = "https://kubernetes-sigs.github.io/node-feature-discovery/charts"
  chart      = "node-feature-discovery"
  version    = var.nfd_chart_version
  namespace  = kubernetes_namespace.nfd_ns.metadata.0.name
}

# external hello world
resource "helm_release" "hello_world_external" {
  name       = "hello-world-external"
  repository = "https://cloudecho.github.io/charts/"
  chart      = "hello"
  version    = var.hello_world_chart_version
  namespace  = "default"

  set = concat(
    [
      {
        name = "ingress.enabled"
        value = false
      },
    ]
  )
}

resource "kubernetes_ingress_v1" "hello_world_ingress_external" {
  metadata {
    name = "hello-world-ingress-external"
    annotations = {
      "cert-manager.io/cluster-issuer" = "cert-manager-webhook-dnsimple-production"
    }
  }
  wait_for_load_balancer = true

  spec {
    ingress_class_name = "nginx-external"
    rule {
      host = "co.ddns.sigil.org" # test value
      http {
        path {
          backend {
            service {
              name = "hello-world-external"
              port {
                number = 8080
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts = [
        "co.ddns.sigil.org"
      ]
      secret_name = "hello-tls-secret"
    }
  }
}

