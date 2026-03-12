output "push_urls" {
  description = "Map of monitor name to full push URL."
  value = {
    for k, m in uptimekuma_monitor_push.monitor :
    k => "${var.uptime_kuma_base_url}/api/push/${m.push_token}?status=up&msg=OK&ping="
  }
}
