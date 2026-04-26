{ inputs, ... }:

{
  microvm.vms.pdmos = {
    flake = inputs.self;
    updateFlake = "git+file:///etc/nixos";
  };

  systemd.network.networks."10-tap-pdmos" = {
    matchConfig.Name = "tap-pdmos";
    addresses = [
      {
        addressConfig.Address = "192.168.100.1/24";
      }
    ];
    networkConfig.IPv4Forwarding = true; # required for routed TAP setup
  };

  # VM needs NAT for outbound internet (routed setup)
  networking.nat = {
    enable = true;
    internalInterfaces = [ "tap-pdmos" ];
    externalInterface = "enp1s0";
  };

  services.nginx.virtualHosts."pdmos.pt" = {
    addSSL = true;
    enableACME = true;
    locations."/".proxyPass = "http://192.168.100.2:80";
  };

  microvm.autostart = [ "pdmos" ];
}
