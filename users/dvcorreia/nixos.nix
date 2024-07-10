{ pkgs, inputs, ... }:

{
  # Since we're using zsh as our shell
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.dvcorreia = {
    isNormalUser = true;
    description = "Diogo Correia";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel" # enable ‘sudo’ for the user
    ];
    shell = pkgs.zsh;
  };

<<<<<<< Updated upstream
  fonts = {
    fontDir.enable = true;
=======
    nix.settings.trusted-users = [ "root" "dvcorreia" ]; # cachix requirement

    fonts = {
      fontDir.enable = true;
>>>>>>> Stashed changes

    packages = [
      pkgs.monaspace
      pkgs.jetbrains-mono
      pkgs.mononoki
    ];
  };
}
