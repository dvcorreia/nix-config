data "cloudflare_zone" "pdmos_pt" {
  zone_id = "cbb59031587371c5e68c8f6741def05d"
}

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
    }
  }

  pdmos_pt = {
    subdomains = {}
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

module "pdmos_pt_dns" {
  source = "./modules/cloudflare_dns"

  domain     = "pdmos.pt"
  zone_id    = data.cloudflare_zone.pdmos_pt.id
  ipv4       = hcloud_primary_ip.sines_primary_ip.ip_address
  ipv6       = hcloud_primary_ip.sines_primary_ipv6.ip_address
  subdomains = local.pdmos_pt.subdomains
}
