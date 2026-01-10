{ pkgs, ... }:

let
  site = pkgs.stdenv.mkDerivation {
    name = "vacinacao-site";
    src = ./site;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
in
{
  services.nginx.virtualHosts."xn--vacinao-2wa9a.pt" = {
    enableACME = true;
    forceSSL = true;

    extraConfig = ''
      server_name vacinação.pt www.vacinação.pt;
    '';

    serverAliases = [
      "www.xn--vacinao-2wa9a.pt"
    ];

    root = site;

    locations."/" = {
      extraConfig = ''
        index index.html;
        try_files $uri $uri/ =404;
      '';
    };

    locations."~* \\.(?:css|js|svg|png|jpg|jpeg|gif|ico)$" = {
      extraConfig = ''
        add_header Cache-Control "public, max-age=31536000, immutable";
      '';
    };
  };

  security.acme.certs."xn--vacinao-2wa9a.pt" = {
    webroot = "/var/lib/acme/acme-challenge";
    extraDomainNames = [ "www.xn--vacinao-2wa9a.pt" ];
  };
}
