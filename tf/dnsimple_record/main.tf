resource "dnsimple_zone_record" "dns_zone" {
  count     = var.dnsimple_domain != null ? 1 : 0
  zone_name = "${var.dnsimple_domain}"
  name      = "${var.dnsimple_record_name}"
  value     = "${var.dnsimple_record_target}"
  type      = "${var.dnsimple_record_type}"
  ttl       = "${var.dnsimple_record_ttl}"
}
