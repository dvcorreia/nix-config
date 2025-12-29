terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.12"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
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
      method = method.aes_gcm.default_encryption_method
      enforced = true
    }

    plan {
      method = method.aes_gcm.default_encryption_method
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
