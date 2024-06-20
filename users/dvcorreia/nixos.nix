{ pkgs, inputs, ... }:

{
    # Since we're using zsh as our shell
    programs.zsh.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.dvcorreia = {
      isNormalUser = true;
      description = "Diogo Correia";
      extraGroups = [ "docker" "networkmanager" "wheel" ];
      shell = pkgs.zsh;
    };

    fonts = {
      fontDir.enable = true;

      packages = [
        pkgs.monaspace
        pkgs.jetbrains-mono
        pkgs.mononoki
      ];
    };
}
