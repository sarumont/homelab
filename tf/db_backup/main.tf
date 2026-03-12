locals {
  pg_image      = "postgres:16-alpine"
  mariadb_image = "mariadb:10.11"

  commands = { for k, v in var.backups : k =>
    join(" && ", compact([
      "mkdir -p /backup/${v.namespace}",
      v.db_type == "postgres"
      ? "PGPASSWORD=\"$DB_PASSWORD\" pg_dumpall -h ${v.db_host} -p ${v.db_port} -U \"$DB_USER\" | gzip > /backup/${v.namespace}/${k}-$(date +%Y%m%d-%H%M%S).sql.gz"
      : "mysqldump -h ${v.db_host} -P ${v.db_port} -u \"$DB_USER\" -p\"$DB_PASSWORD\" --all-databases | gzip > /backup/${v.namespace}/${k}-$(date +%Y%m%d-%H%M%S).sql.gz",
      "find /backup/${v.namespace} -name '${k}-*.sql.gz' -mtime +${var.retention_days} -delete",
      v.push_url != "" ? "curl -fsS -m 10 --retry 3 \"$PUSH_URL\" > /dev/null" : "",
    ]))
  }
}

resource "kubernetes_cron_job_v1" "backup" {
  for_each = var.backups

  metadata {
    name      = "${each.key}-backup"
    namespace = each.value.namespace
  }

  spec {
    schedule                      = each.value.schedule
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 1
    concurrency_policy            = "Forbid"

    job_template {
      metadata {}

      spec {
        template {
          metadata {}

          spec {
            restart_policy = "OnFailure"

            container {
              name    = "backup"
              image   = each.value.db_type == "postgres" ? local.pg_image : local.mariadb_image
              command = ["/bin/sh", "-c"]
              args    = [local.commands[each.key]]

              # DB_USER: from db_user variable if set, otherwise from secret
              dynamic "env" {
                for_each = each.value.db_user != null ? [1] : []
                content {
                  name  = "DB_USER"
                  value = each.value.db_user
                }
              }
              dynamic "env" {
                for_each = each.value.db_user == null ? [1] : []
                content {
                  name = "DB_USER"
                  value_from {
                    secret_key_ref {
                      name = each.value.secret_name
                      key  = each.value.secret_username_key
                    }
                  }
                }
              }

              env {
                name = "DB_PASSWORD"
                value_from {
                  secret_key_ref {
                    name = each.value.secret_name
                    key  = each.value.secret_password_key
                  }
                }
              }

              dynamic "env" {
                for_each = each.value.push_url != "" ? [1] : []
                content {
                  name  = "PUSH_URL"
                  value = each.value.push_url
                }
              }

              volume_mount {
                name       = "backup-storage"
                mount_path = "/backup"
              }
            }

            volume {
              name = "backup-storage"
              nfs {
                server = var.nfs_server
                path   = var.nfs_path
              }
            }
          }
        }
      }
    }
  }
}
