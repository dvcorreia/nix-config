variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API token with access to the required zones"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare Zone ID for dvcorreia.com"
}

variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud API token"
  sensitive   = true
}

variable "ssh_pub_key" {
  type        = string
  description = "Path to public SSH key that will be copied on the VMs"
}
