provider "mysql" {
  endpoint = var.provider_db_addr
  username = "root"
  password = "${var.db_root_password}"
}

resource "random_password" "db_password" {
  length           = 16
  special          = false
}

resource "mysql_user" "db_user" {
  user               = var.db_user
  host               = "%"
  plaintext_password = "${random_password.db_password.result}"
}

resource "mysql_database" "db" {
  name = var.db_name
}

resource "mysql_grant" "db_grant" {
  user       = "${mysql_user.db_user.user}"
  host       = "${mysql_user.db_user.host}"
  database   = "${mysql_database.db.name}"
  privileges = ["ALL"]
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "dnsimple_zone_record" "cname" {
  count     = var.dnsimple_domain != null ? 1 : 0
  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}

resource "helm_release" "photoprism" {
  name       = "photoprism"
  repository = "https://sarumont.github.io/homelab"
  chart      = "photoprism"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name

  dynamic "set" {
    for_each = var.ingress_hosts
    content {
      name  = "ingress.hosts[${set.key}].host"
      value = "${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.ingress_hosts
    content {
      name  = "ingress.hosts[${set.key}].paths[0]"
      value = "/"
    }
  }

  values = [
<<EOT
image:
  tag: ${var.image_version}
ingress:
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    "cert-manager.io/cluster-issuer": "cert-manager-webhook-dnsimple-production"
  className: ${var.ingress_class_name}
  enabled: true
  tls:
  - hosts:
    - ${var.tls_host}
    secretName: photoprism-cert
config:
  PHOTOPRISM_DEBUG: true
  PHOTOPRISM_READONLY: false
  PHOTOPRISM_WORKERS: 2
  PHOTOPRISM_AUTH_MODE: password
  PHOTOPRISM_SITE_URL: ${var.site_url}
persistence:
  enabled: true
  storagePath:   &storagePath    /photoprism/storage
  originalsPath: &originalsPath  /photoprism/originals
  importPath:    &importPath     /photoprism/import
  volumeMounts:
  - name: originals
    mountPath: *originalsPath
  - name: storage
    mountPath: *storagePath
  - name: imports
    mountPath: *importPath
  volumes:
  - name: originals
    nfs:
      server: ${var.nfs_server}
      path: ${var.originals_path}
  - name: storage
    nfs:
      server: ${var.nfs_server}
      path: ${var.storage_path}
  - name: imports
    nfs:
      server: ${var.nfs_server}
      path: ${var.imports_path}
    
database:
  driver: mysql
  name: ${mysql_database.db.name}
  user: ${mysql_user.db_user.user}
  password: ${random_password.db_password.result}
  port: 3306
  host: ${var.db_addr}
resources: 
    requests: 
        gpu.intel.com/i915: "1" 
    limits: 
        gpu.intel.com/i915: "1" 
EOT
  ]
}
