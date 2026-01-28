let
  keys = import ./ssh-keys.nix;
  inherit (keys) dvcorreia;
in
{
  "cloudflare-dns-token.age".publicKeys = [ dvcorreia ];
  "hetzner-homelab-api-token.age".publicKeys = [ dvcorreia ];
  "opentofu-encryption-key.age".publicKeys = [ dvcorreia ];

  "pocket-id.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
  "headscale-oidc.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
}
