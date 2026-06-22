resource "hcloud_ssh_key" "default" {
  name       = "fido2-yubikey"
  public_key = var.ssh_pub_key
}

data "hcloud_datacenter" "helsinki_datacenter" {
  name = "hel1-dc2"
}

resource "hcloud_primary_ip" "sines_primary_ip" {
  name          = "sines-primary-ip"
  location      = data.hcloud_datacenter.helsinki_datacenter.location.name
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_primary_ip" "sines_primary_ipv6" {
  name          = "sines-primary-ipv6"
  location      = data.hcloud_datacenter.helsinki_datacenter.location.name
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_rdns" "sines_ipv4" {
  primary_ip_id = hcloud_primary_ip.sines_primary_ip.id
  ip_address    = hcloud_primary_ip.sines_primary_ip.ip_address
  dns_ptr       = "mail.dvcorreia.com"
}

resource "hcloud_rdns" "sines_ipv6" {
  primary_ip_id = hcloud_primary_ip.sines_primary_ipv6.id
  ip_address    = hcloud_primary_ip.sines_primary_ipv6.ip_address
  dns_ptr       = "mail.dvcorreia.com"
}

resource "hcloud_server" "sines" {
  name        = "sines"
  image       = "debian-13"
  server_type = "cx23"
  location    = data.hcloud_datacenter.helsinki_datacenter.location.name
  ssh_keys    = [hcloud_ssh_key.default.id]
  public_net {
    ipv4 = hcloud_primary_ip.sines_primary_ip.id
    ipv6 = hcloud_primary_ip.sines_primary_ipv6.id
  }
}
