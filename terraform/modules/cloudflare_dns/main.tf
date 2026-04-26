terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.18"
    }
  }
}

locals {
  dns_record_comment = "Managed by OpenTofu at https://github.com/dvcorreia/nix-config"
}

resource "cloudflare_dns_record" "root_a" {
  zone_id = var.zone_id
  name    = "@"
  content = var.ipv4
  type    = "A"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "root_aaaa" {
  zone_id = var.zone_id
  name    = "@"
  content = var.ipv6
  type    = "AAAA"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "www_cname" {
  zone_id = var.zone_id
  name    = "www"
  content = var.domain
  type    = "CNAME"
  proxied = true
  ttl     = 1
  comment = local.dns_record_comment
}

resource "cloudflare_dns_record" "subdomain_a" {
  for_each = var.subdomains

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain}"
  content = var.ipv4
  type    = "A"

  proxied = try(each.value.proxied, true)
  ttl     = try(each.value.ttl, 1)

  comment = join(
    " | ",
    compact([
      try(each.value.description, null),
      local.dns_record_comment,
    ])
  )
}

resource "cloudflare_dns_record" "subdomain_aaaa" {
  for_each = var.subdomains

  zone_id = var.zone_id
  name    = "${each.key}.${var.domain}"
  content = var.ipv6
  type    = "AAAA"

  proxied = try(each.value.proxied, true)
  ttl     = try(each.value.ttl, 1)

  comment = join(
    " | ",
    compact([
      try(each.value.description, null),
      local.dns_record_comment,
    ])
  )
}
