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

  # The autoconnect unit waits for tailscaled to reach Running. When the
  # control-plane dial races a network restart during activation this can take
  # a couple of minutes, which exceeds systemd's 90s default and fails the
  # whole activation (deploy-rs then rolls back).
  systemd.services.tailscaled-autoconnect.serviceConfig.TimeoutStartSec = "5min";
}
