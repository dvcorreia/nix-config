{ config, inputs, ... }:

let
  headscaleUrl = inputs.self.nixosConfigurations.sines.config.services.headscale.settings.server_url;
in
{
  age.secrets.nas-tailscale-preauth-key.file = ../../secrets/nas-tailscale-preauth-key.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.nas-tailscale-preauth-key.path;
    extraUpFlags = [
      "--login-server=${headscaleUrl}"
      "--accept-dns=true" # accept MagicDNS
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
