variable "domain" {
  type        = string
  description = "Domain name"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare zone ID"
}

variable "ipv4" {
  type        = string
  description = "IPv4 address for A records"
}

variable "ipv6" {
  type        = string
  description = "IPv6 address for AAAA records"
}

variable "subdomains" {
  type = map(object({
    proxied     = optional(bool, true)
    ttl         = optional(number, 1)
    description = optional(string, null)
  }))
  default     = {}
  description = "Map of subdomain configurations"
}

variable "dns_record_comment" {
  type        = string
  default     = "Managed by Terraform"
  description = "Comment added to all DNS records"
}
