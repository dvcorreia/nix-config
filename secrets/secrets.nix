let
  keys = import ./ssh-keys.nix;
  inherit (keys) dvcorreia;
in
{
  "cloudflare-dns-token.age".publicKeys = [ dvcorreia ];
  "hetzner-homelab-api-token.age".publicKeys = [ dvcorreia ];
  "opentofu-encryption-key.age".publicKeys = [ dvcorreia ];
  "proart-tailscale-preauth-key.age".publicKeys = [
    dvcorreia
    keys.proart-7950x
  ];

  "pocket-id.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
  "headscale-oidc.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
  "grafana-secret-key.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
  "grafana-oauth2-client-secret.age".publicKeys = [
    dvcorreia
    keys.sines
  ];
}
