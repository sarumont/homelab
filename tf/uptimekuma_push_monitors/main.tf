resource "uptimekuma_monitor_push" "monitor" {
  for_each = var.monitors

  name     = each.key
  interval = each.value
  active   = true
}
