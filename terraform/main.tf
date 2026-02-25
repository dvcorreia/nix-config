terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.18"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.11"
    }
  }

  encryption {
    key_provider "pbkdf2" "encryption_key" {
      passphrase = var.passphrase
    }

    method "aes_gcm" "default_encryption_method" {
      keys = key_provider.pbkdf2.encryption_key
    }

    state {
      method   = method.aes_gcm.default_encryption_method
      enforced = true
    }

    plan {
      method   = method.aes_gcm.default_encryption_method
      enforced = true
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

data "cloudflare_zone" "dvcorreia_com" {
  zone_id = var.cloudflare_zone_id
}
