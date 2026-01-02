locals {
  dns_record_comment = "Managed by Terraform (gh:dvcorreia/nix-config)"
}

# ----------- dvcorreia.com ----------- #

locals {
  dvcorreia_com_domain = "dvcorreia.com"
  dvcorreia_com_subdomains = {
    # name    proxy status
    id = true
  }
}

data "cloudflare_zone" "dvcorreia_com" {
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_dns_record" "dvcorreia_com_cname" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "www"
  content = local.dvcorreia_com_domain
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "dvcorreia_com_a" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "@"
  content = hcloud_primary_ip.sines_primary_ip.ip_address
  type    = "A"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "dvcorreia_com_aaaa" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "@"
  content = hcloud_primary_ip.sines_primary_ipv6.ip_address
  type    = "AAAA"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "dvcorreia_com_subdomain_cname" {
  for_each = local.dvcorreia_com_subdomains

  zone_id = data.cloudflare_zone.dvcorreia_com.id
  name    = "${each.key}.${local.dvcorreia_com_domain}"
  content = local.dvcorreia_com_domain
  type    = "CNAME"
  proxied = each.value
  ttl     = 1
  comment = local.dns_record_comment
}
