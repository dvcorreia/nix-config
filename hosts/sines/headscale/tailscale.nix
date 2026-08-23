{
  inputs,
  config,
  ...
}:

let
  headscaleUrl = inputs.self.nixosConfigurations.sines.config.services.headscale.settings.server_url;
in
{
  age.secrets.sines-tailscale-preauth-key.file = ../../../secrets/sines-tailscale-preauth-key.age;

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = config.age.secrets.sines-tailscale-preauth-key.path;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--login-server=${headscaleUrl}"
      "--accept-dns=true" # accept MagicDNS
      "--advertise-exit-node"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
