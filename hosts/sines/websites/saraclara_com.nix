{ ... }:
{
  services.nginx.virtualHosts."saraclara.com" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      return = ''200 '<img src="https://gifsec.com/wp-content/uploads/2022/09/middle-finger-gif-3.gif" />' '';
      extraConfig = ''
        default_type text/html;
      '';
    };
  };
}
