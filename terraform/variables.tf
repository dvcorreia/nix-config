variable "passphrase" {
  sensitive   = true
  description = "OpenTofu state/plan passphrase"
}

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

variable "ovh_application_key" {
  type        = string
  description = "OVH Application Key"
}

variable "ovh_application_secret" {
  type        = string
  sensitive   = true
  description = "OVH Application Secret"
}

variable "ovh_consumer_key" {
  type        = string
  sensitive   = true
  description = "OVH Consumer Key"
}
