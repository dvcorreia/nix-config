{
  # These stay master-encrypted for agenix-shell; activation only receives dummy files.
  age.secrets = {
    hetzner-homelab-api-token = {
      rekeyFile = ../../secrets/hetzner-homelab-api-token.age;
      intermediary = true;
    };
    cloudflare-dns-token = {
      rekeyFile = ../../secrets/cloudflare-dns-token.age;
      intermediary = true;
    };
    opentofu-encryption-key = {
      rekeyFile = ../../secrets/opentofu-encryption-key.age;
      intermediary = true;
    };
  };
}
