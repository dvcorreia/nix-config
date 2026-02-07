{
  config,
  inputs,
  ...
}:

let
  headscaleUrl = inputs.self.nixosConfigurations.sines.config.services.headscale.settings.server_url;
in
{
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets.proart-tailscale-preauth-key.file = ../../secrets/proart-tailscale-preauth-key.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.proart-tailscale-preauth-key.path;
    extraUpFlags = [
      "--login-server=${headscaleUrl}"
      "--accept-dns=true" # accept MagicDNS
    ];
  };
}
