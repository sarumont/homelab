resource "kubernetes_namespace" "pihole_ns" {
  metadata {
    name = "pihole"
  }
}

resource "random_password" "admin_password" {
  length           = 32
  special          = true
}

resource "helm_release" "unbound" {
  name       = "unbound"
  repository = "https://sarumont.github.io/homelab"
  chart      = "unbound"
  version    = var.unbound_chart_version
  namespace  = kubernetes_namespace.pihole_ns.metadata.0.name
  values = [
<<EOT
image: 
  tag: ${var.unbound_image_tag}

service:
  spec:
    loadBalancerIP: ${var.unbound_ip}

additionalConfig: |
    ${var.unbound_additional_config}
EOT
  ]
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
  FTLCONF_dns_listeningMode: 'all'

podDnsConfig:
  enabled: true
  policy: "None"
  nameservers:
  - 127.0.0.1
  - ${var.unbound_ip}
  - 9.9.9.9

DNS1: ${var.unbound_ip}
DNS2: ""

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
EOT
  ]
}
