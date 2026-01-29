resource "cloudflare_access_rule" "sines_server_whitelist" {
  zone_id = data.cloudflare_zone.dvcorreia_com.id
  notes   = "Allow sines server to bypass Bot Fight Mode"

  configuration = {
    target = "ip"
    value  = hcloud_primary_ip.sines_primary_ip.ip_address
  }

  mode = "whitelist"
}