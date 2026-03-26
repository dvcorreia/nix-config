{
  config,
  inputs,
  lib,
  pkgs,
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
    useRoutingFeatures = "both";
    extraUpFlags = [
      "--login-server=${headscaleUrl}"
      "--accept-dns=true" # accept MagicDNS
      "--advertise-exit-node"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # enable udp gro forwarding for better tailscale exit node throughput
  services.networkd-dispatcher = lib.mkIf config.services.tailscale.enable {
    enable = true;
    rules."50-tailscale" = {
      onState = [ "routable" ];
      script = ''
        NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")
        ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
      '';
    };
  };
}
