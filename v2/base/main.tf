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
    value = true
  }
}

# resource "kubernetes_namespace" "k8s_dashboard" {
#   metadata {
#     name = "k8s-dashboard"
#   }
# }

# resource "helm_release" "k8s_dashboard" {
#   name       = "k8s-dashboard"
#   repository = "https://kubernetes.github.io/dashboard"
#   chart      = "kubernetes-dashboard"
#   version    = var.k8s_dashboard_chart_version
#   namespace  = kubernetes_namespace.k8s_dashboard.metadata.0.name
#
#   values = [
# <<EOT
# app:
#   ingress:
#     enabled: true
#     hosts:
#     - dashboard.homelab.local
# metrics-server:
#   enabled: false
# nginx:
#   enabled: false
# EOT
#   ]
# }

# resource "kubernetes_namespace" "authelia" {
#   metadata {
#     name = "authelia"
#   }
# }
#
# resource "helm_release" "authelia" {
#   name       = "authelia"
#   repository = "https://charts.authelia.com"
#   chart      = "authelia"
#   version    = var.authelia_chart_version
#   namespace  = kubernetes_namespace.authelia.metadata.0.name
#
#   values = [
# <<EOT
# ingress:
#   enabled: true
# EOT
#   ]
# }

#$ helm install my-hello cloudecho/hello -n default --version=0.1.2

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
      host = "dashboard.${var.cluster_domain}"
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
