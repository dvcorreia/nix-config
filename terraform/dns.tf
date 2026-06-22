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
      ai = {
        proxied     = true
        description = "Open WebUI"
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
  content = "v=DMARC1; p=quarantine"
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

resource "cloudflare_dns_record" "dvcorreia_com_dkim" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "mail._domainkey"
  content = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4B40XOui0fNtdkgo/30PYEIwRaVDFITiAvlkCdCqhMGFXDwizzkm5Ei/Nj5fhO+awq5fFi9G60U1LPJnbCa6bUGaogtfk+KeFnerx3rcsU3opuZokuEhdg5q0764ETm+HC4yHK6py6V2z+8jkRMD+PM3iP5v/5Zk679m4c5YZ3jTdKZmXxG3p1JR9UqialxSHZ9YRg64yl5bwMORxHgOlw8tGICW0tb6vJY5LMGL+iZitbv8wwcCgL5NYHt/RWZ8VF44DNZYrTcNbYwyCmDahwItT1i8x5CAiH94TlCSaAo3gbPTIr5JNGN0hfuff1agKmsxTlC6JKCvoSr7e44b/QIDAQAB"
  type    = "TXT"
  ttl     = 3600
  comment = "DKIM key for dvcorreia.com (selector: mail)"
}

resource "cloudflare_dns_record" "srs_dvcorreia_com_dkim" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "mail._domainkey.srs"
  content = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArSKkD3sB/nthJnlCQqygPFiBYZ4Le2dCcfEWhPUkPlcdXHLP9SlPBLGd23YyUWrbtG57mhET6M/e/j+pEXa4ZxNubT87MT8UA9xKrLycxCtJYfSz3QIQFwFY221koBvDZGs5NahOqPPjFfFuFlovGQefaShTdo+AEHR7q8v3+m1JhhJ8IV5K/cR1VBcPRftVp9Av22+YHFEcumxrfcXIEI9C66Rlf/llwKcdBR8oILFk35cco6A9IzSnwoWrmpnoGTfIrQI0T4YqjxM9CuLKxE9ewKFwVl+b58dh8SMVXXENip1qBC2GQDhRQUA1U6AG6Ehy+sbNPgr1QsQy0tVC5QIDAQAB"
  type    = "TXT"
  ttl     = 3600
  comment = "DKIM key for srs.dvcorreia.com (selector: mail)"
}

resource "cloudflare_dns_record" "srs_dvcorreia_com_spf" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "srs"
  content = "v=spf1 mx -all"
  type    = "TXT"
  ttl     = 10800
  comment = "SPF record for SRS domain"
}
