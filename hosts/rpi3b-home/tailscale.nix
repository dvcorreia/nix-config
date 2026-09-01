{ config, inputs, ... }:

let
  headscaleUrl = inputs.self.nixosConfigurations.sines.config.services.headscale.settings.server_url;
in
{
  age.secrets.rpi3b-home-tailscale-preauth-key.file = ../../secrets/rpi3b-home-tailscale-preauth-key.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.rpi3b-home-tailscale-preauth-key.path;
    extraUpFlags = [
      "--login-server=${headscaleUrl}"
      "--accept-dns=true" # accept MagicDNS
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
