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
}

module "dvcorreia_com_dns" {
  source = "./modules/cloudflare_dns"

  domain     = "dvcorreia.com"
  zone_id    = data.cloudflare_zone.dvcorreia_com.id
  ipv4       = hcloud_primary_ip.sines_primary_ip.ip_address
  ipv6       = hcloud_primary_ip.sines_primary_ipv6.ip_address
  subdomains = local.dvcorreia_com.subdomains
}
