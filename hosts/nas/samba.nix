{ ... }:

{
  services.samba = {
    enable = true;
    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "nas";
        "security" = "user";
        "server min protocol" = "SMB2_10";
      };

      storage = {
        path = "/mnt/storage";
        browseable = "yes";
        "read only" = "no";
        "valid users" = "dvcorreia";
        "force user" = "dvcorreia";
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 445 ];
}
