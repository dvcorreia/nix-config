{ pkgs, inputs, ... }:

{
    # Since we're using fish as our shell
    programs.fish.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.dvcorreia = {
      isNormalUser = true;
      description = "Diogo Correia";
      extraGroups = [ "docker" "networkmanager" "wheel" ];
      shell = pkgs.fish;
    };

    fonts = {
      fontDir.enable = true;

      packages = [
        pkgs.monaspace
        pkgs.jetbrains-mono
        pkgs.mononoki
      ];
    };

    services.transmission.enable = true;
}
