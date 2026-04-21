{
  inputs,
  pkgs,
  ...
}:

let
  inherit (inputs.sensei-code-challenge.packages.${pkgs.system}) sensei;
in
{
  systemd.services.sensei = {
    description = "Sensei People Detection Service";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.lib.getExe sensei}";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "PORT=8000"
        "HOST=127.0.0.1"
      ];
    };
  };

  services.nginx.virtualHosts."sensei.dvcorreia.com" = {
    forceSSL = true;
    enableACME = true;
    serverName = "sensei.dvcorreia.com";

    locations."/" = {
      proxyPass = "http://127.0.0.1:8000";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50M;
        proxy_read_timeout 60s;
        proxy_send_timeout 60s;
      '';
    };
  };
}
