# MetalLB
resource "kubernetes_namespace" "metallb_ns" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace.metallb_ns.metadata.0.name
}

resource "kubernetes_manifest" "lb_pool" {
  manifest = {
    "apiVersion" = "metallb.io/v1beta1"
    "kind"       = "IPAddressPool"
    "metadata" = {
      "name"      = "lb-pool"
      "namespace"  = kubernetes_namespace.metallb_ns.metadata.0.name
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
      "namespace"  = kubernetes_namespace.metallb_ns.metadata.0.name
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

# Persistent storage via NFS
resource "helm_release" "nfs_pvc" {
  name = "nfs-subdir-external-provisioner"
  repository = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/"
  chart = "nfs-subdir-external-provisioner"
  version = "4.0.18"
  namespace = "kube-system"

  set {
    name = "nfs.server"
    value = var.nfs_server
  }

  set {
    name = "nfs.path"
    value = var.nfs_path
  }

  set {
    name = "storageClass.defaultClass"
    value = false
  }
}

# hello world app
resource "helm_release" "hello_world" {
  name       = "hello-world"
  repository = "https://cloudecho.github.io/charts/"
  chart      = "hello"
  version    = "0.1.2"
  namespace  = "default"

  set {
    name = "ingress.enabled"
    value = false
  }
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
  source        = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email                   = "admin@sigil.org"
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
