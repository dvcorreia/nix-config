let
  keys = import ./ssh-keys.nix { };
in
{
  "cloudflare-dns-token.age".publicKeys = [ keys.dvcorreia ];
  "hetzner-homelab-api-token.age".publicKeys = [ keys.dvcorreia ];
  "opentofu-encryption-key.age".publicKeys = [ keys.dvcorreia ];
}
