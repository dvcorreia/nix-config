{
  inputs,
  pkgs,
  ...
}:

{
  services.nginx.virtualHosts."dvcorreia.com" = {
    addSSL = true;
    enableACME = true;

    root = "${inputs.dvcorreia-website.packages.${pkgs.system}.default}/share/dvcorreia-website";

    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ =404";
      extraConfig = ''
        error_page 404 /404.html;
      '';
    };
  };
}
