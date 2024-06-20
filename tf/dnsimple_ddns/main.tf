resource "kubernetes_secret" "dnsimple_creds" {
  metadata {
    name = "dnsimple-creds"
  }

  data = {
    TOKEN = var.dnsimple_token
    ACCOUNT = var.account
    ZONE_ID = var.zone_id
    RECORD_ID = var.record_id
  }

  type = "opaque"
}

resource "kubernetes_cron_job_v1" "dnsimple_ddns" {
  metadata {
    name = "dnsimple-ddns"
  }
  spec {
    failed_jobs_history_limit     = 5
    schedule                      = "0 */1 * * *"
    successful_jobs_history_limit = 10
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name    = "dnsimple-ddns"
              image   = "docker.io/sarumont/dddns:latest"
              command = ["/root/dddns"]
              env_from { 
                secret_ref { 
                    name = kubernetes_secret.dnsimple_creds.metadata.0.name
                }
              }
            }
          }
        }
      }
    }
  }
}
