resource "dnsimple_zone_record" "dns_zone" {
  for_each = { for r in var.dnsimple_records: "${r.name}.${r.domain}" => r }

  zone_name = each.value.domain
  name      = each.value.name
  value     = each.value.target
  type      = each.value.type
  ttl       = each.value.ttl
}
