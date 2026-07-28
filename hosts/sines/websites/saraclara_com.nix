{ config, lib, ... }:

{
  services.instatic = {
    enable = true;
    port = 3002;
    publicOrigin = "https://saraclara.com";
  };

  services.nginx.virtualHosts."www.saraclara.com" = {
    addSSL = true;
    enableACME = true;
    globalRedirect = "saraclara.com";
  };

  services.nginx.virtualHosts."saraclara.com" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.instatic.port}";
      proxyWebsockets = true;
    };
    extraConfig = ''
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $host;
    '';
  };
}
