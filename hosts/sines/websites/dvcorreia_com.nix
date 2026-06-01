{
  inputs,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  services.nginx.virtualHosts."dvcorreia.com" = {
    addSSL = true;
    enableACME = true;

    root = "${inputs.dvcorreia-website.packages.${system}.default}/share/dvcorreia-com";

    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ =404";
      extraConfig = ''
        error_page 404 /404.html;
      '';
    };
  };
}
