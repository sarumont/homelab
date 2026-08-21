output "push_urls" {
  description = "Map of monitor name to full push URL."
  sensitive   = true
  value = {
    for k, m in uptimekuma_monitor_push.monitor :
    k => "${var.uptime_kuma_base_url}/api/push/${m.push_token}?status=up&msg=OK&ping="
  }
}

output "push_tokens" {
  description = "Map of monitor name to push token."
  sensitive   = true
  value = {
    for k, m in uptimekuma_monitor_push.monitor :
    k => m.push_token
  }
}
