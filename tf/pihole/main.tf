resource "kubernetes_namespace" "pihole_ns" {
  metadata {
    name = "pihole"
  }
}

resource "random_password" "admin_password" {
  length           = 32
  special          = true
}

resource "helm_release" "pihole" {
  name       = "pihole"
  repository = "https://mojo2600.github.io/pihole-kubernetes/"
  chart      = "pihole"
  version    = var.chart_version
  namespace  = kubernetes_namespace.pihole_ns.metadata.0.name

  # Note that these won't show up in the Web UI, but they will work
  dynamic "set" {
    for_each = var.custom_dns_entries
    content {
      name  = "dnsmasq.customDnsEntries[${set.key}]"
      value = "${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.custom_cname_entries
    content {
      name  = "dnsmasq.customCnameEntries[${set.key}]"
      value = "${set.value}"
    }
  }

  values = [
<<EOT
extraEnvVars: 
  TZ: ${var.timezone}

podDnsConfig:
  enabled: true
  policy: "None"
  nameservers:
  - 127.0.0.1
  - 9.9.9.9

DNS1: 9.9.9.9
DNS2: 1.1.1.1

hostname: pihole

adminPassword: "${random_password.admin_password.result}"

persistentVolumeClaim:
  enabled: true

# allow both the web and DNS servers to run on the same IP
serviceWeb:
  loadBalancerIP: ${var.ip}
  annotations:
    metallb.universe.tf/allow-shared-ip: pihole-svc
  type: LoadBalancer

serviceDns:
  loadBalancerIP: ${var.ip}
  annotations:
    metallb.universe.tf/allow-shared-ip: pihole-svc
  type: LoadBalancer

# not using DHCP
serviceDhcp:
  enabled: false

resources:
  requests:
    memory: 128Mi
    cpu: 100m
  limits:
    memory: 2Gi
    cpu: 1
EOT
  ]
}
