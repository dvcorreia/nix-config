{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  networking.hostName = "pdmos";

  microvm = {
    hypervisor = "qemu";
    vcpu = 1;
    mem = 512;

    interfaces = [
      {
        type = "tap";
        id = "tap-pdmos";
        mac = "02:00:00:00:00:01";
      }
    ];

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];
  };

  systemd.network = {
    enable = true;
    networks."10-eth" = {
      matchConfig.MACAddress = "02:00:00:00:00:01";
      addresses = [
        {
          addressConfig.Address = "192.168.100.2/24";
        }
      ];
      routes = [
        {
          routeConfig = {
            Gateway = "192.168.100.1";
            GatewayOnLink = true; # Required for point-to-point TAP (no ARP)
          };
        }
      ];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."pdmos.pt" = {
      root = pkgs.writeTextDir "index.html" ''
        <!DOCTYPE html>
        <html>
        <head><title>pdmos.pt</title></head>
        <body><h1>Hello, World!</h1></body>
        </html>
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "24.11";
}
