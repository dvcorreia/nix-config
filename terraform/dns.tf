data "cloudflare_zone" "dvcorreia_com" {
  zone_id = "6f9c7fc4fe11ede15a136982bedcad85"
}

locals {
  dvcorreia_com = {
    subdomains = {
      id = {
        proxied     = true
        description = "Pocket ID OIDC server"
      }
      headscale = {
        proxied     = false # https://headscale.net/stable/ref/integration/reverse-proxy/#cloudflare
        ttl         = 3600
        description = "Headscale server"
      }
      monitor = {
        proxied     = true
        description = "Grafana for infrastructure monitor"
      }
      mail = {
        proxied     = false
        ttl         = 3600
        description = "Mailserver"
      }
      srs = {
        proxied     = false
        ttl         = 3600
        description = "SRS domain for mail forwarding"
      }
    }
  }
}

module "dvcorreia_com_dns" {
  source = "./modules/cloudflare_dns"

  domain     = "dvcorreia.com"
  zone_id    = data.cloudflare_zone.dvcorreia_com.id
  ipv4       = hcloud_primary_ip.sines_primary_ip.ip_address
  ipv6       = hcloud_primary_ip.sines_primary_ipv6.ip_address
  subdomains = local.dvcorreia_com.subdomains
}

resource "cloudflare_dns_record" "dvcorreia_com_mx" {
  zone_id  = data.cloudflare_zone.dvcorreia_com.id
  name     = "@"
  content  = "mail.dvcorreia.com"
  type     = "MX"
  ttl      = 3600
  priority = 10
  comment  = "Mailserver MX record"
}

resource "cloudflare_dns_record" "dvcorreia_com_spf" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "@"
  content = "v=spf1 mx -all"
  type    = "TXT"
  ttl     = 86400
  comment = "SPF record for mailserver"
}

resource "cloudflare_dns_record" "dvcorreia_com_dmarc" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "_dmarc"
  content = "v=DMARC1; p=none"
  type    = "TXT"
  ttl     = 86400
  comment = "DMARC record for mailserver"
}

resource "cloudflare_dns_record" "srs_dvcorreia_com_mx" {
  zone_id  = data.cloudflare_zone.dvcorreia_com.id
  name     = "srs"
  content  = "mail.dvcorreia.com"
  type     = "MX"
  ttl      = 10800
  priority = 10
  comment  = "SRS domain MX record for mail forwarding"
}

resource "cloudflare_dns_record" "srs_dvcorreia_com_spf" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "srs"
  content = "v=spf1 mx -all"
  type    = "TXT"
  ttl     = 10800
  comment = "SPF record for SRS domain"
}
