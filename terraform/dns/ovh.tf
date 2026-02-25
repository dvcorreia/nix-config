# ----------- pdmos.pt ----------- #

locals {
  pdmos_pt_zone       = "pdmos.pt"
  pdmos_pt_subdomains = {
    id = {
      description = "Pocket ID OIDC server"
    }
  }
}

resource "ovh_domain_zone_record" "pdmos_pt_a" {
  zone      = local.pdmos_pt_zone
  subdomain = ""
  fieldtype = "A"
  target    = hcloud_primary_ip.sines_primary_ip.ip_address
}

resource "ovh_domain_zone_record" "pdmos_pt_aaaa" {
  zone      = local.pdmos_pt_zone
  subdomain = ""
  fieldtype = "AAAA"
  target    = hcloud_primary_ip.sines_primary_ipv6.ip_address
}

resource "ovh_domain_zone_record" "pdmos_pt_subdomain_a" {
  for_each = local.pdmos_pt_subdomains

  zone      = local.pdmos_pt_zone
  subdomain = each.key
  fieldtype = "A"
  target    = hcloud_primary_ip.sines_primary_ip.ip_address
}

resource "ovh_domain_zone_record" "pdmos_pt_subdomain_aaaa" {
  for_each = local.pdmos_pt_subdomains

  zone      = local.pdmos_pt_zone
  subdomain = each.key
  fieldtype = "AAAA"
  target    = hcloud_primary_ip.sines_primary_ipv6.ip_address
}
