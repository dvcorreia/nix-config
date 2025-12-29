resource "hcloud_ssh_key" "default" {
  name       = "fido2-yubikey"
  public_key = var.ssh_pub_key
}

# datacenters list:
# https://docs.hetzner.com/cloud/general/locations/#what-datacenters-are-there

data "hcloud_datacenter" "helsinki_datacenter" {
  name = "hel1-dc2"
}

# ----------- sines ----------- #

resource "hcloud_primary_ip" "sines_primary_ip" {
  name          = "sines-primary-ip"
  datacenter    = data.hcloud_datacenter.helsinki_datacenter.name
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_primary_ip" "sines_primary_ipv6" {
  name          = "sines-primary-ipv6"
  datacenter    = data.hcloud_datacenter.helsinki_datacenter.name
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = true
}

resource "hcloud_server" "sines" {
  name        = "sines"
  image       = "debian-13"
  server_type = "cx23"
  datacenter  = data.hcloud_datacenter.helsinki_datacenter.name
  ssh_keys    = [hcloud_ssh_key.default.id]
  public_net {
    ipv4 = hcloud_primary_ip.sines_primary_ip.id
    ipv6 = hcloud_primary_ip.sines_primary_ipv6.id
  }
}
