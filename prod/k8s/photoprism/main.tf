# Configure the MySQL provider
provider "mysql" {
  endpoint = "localhost:32306"
  username = "root"
  password = "${var.db_root_password}"
}

resource "random_password" "photoprism_db_password" {
  length           = 16
  special          = false
}

resource "mysql_user" "photoprism_db_user" {
  user               = "photoprism"
  host               = "%"
  plaintext_password = "${random_password.photoprism_db_password.result}"
}

resource "mysql_database" "photoprism_db" {
  name = "photoprism"
}

resource "mysql_grant" "photoprism_db_grant" {
  user       = "${mysql_user.photoprism_db_user.user}"
  host       = "${mysql_user.photoprism_db_user.host}"
  database   = "${mysql_database.photoprism_db.name}"
  privileges = ["ALL"]
}

resource "helm_release" "photoprism" {
  name       = "photoprism"
  repository = "../../../../" # https://p80n.github.io/photoprism-helm/"
  chart      = "photoprism-helm" #"photoprism"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.port"
    value = "2342"
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}].host"
      value = "photos.${set.value}"
    }
  }

  dynamic "set" {
    for_each = var.domains
    content {
      name  = "ingress.hosts[${set.key}].paths[0]"
      value = "/"
    }
  }

  values = [
<<EOT
replicaCount: ${var.replica_count}
image:
  tag: ${var.photoprism_image_tag}
  pullPolicy: Always
config:
  PHOTOPRISM_DEBUG: true
  PHOTOPRISM_READONLY: false
  PHOTOPRISM_PUBLIC: false
  PHOTOPRISM_WORKERS: 2
ingress:
  enabled: true
  tls: []
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
    hostPath:
      path: ${var.photoprism_originals_path}
  - name: storage
    hostPath:
      path: ${var.photoprism_storage_path}
  - name: imports
    hostPath:
      path: ${var.photoprism_imports_path}
database:
  driver: mysql
  name: ${mysql_database.photoprism_db.name}
  user: ${mysql_user.photoprism_db_user.user}
  password: ${random_password.photoprism_db_password.result}
  port: 3306
  host: mariadb.shared.svc.cluster.local
EOT
  ]
}
