{ pkgs, inputs, ... }:

{
  # Since we're using zsh as our shell
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’
  users.users.dvcorreia = {
    isNormalUser = true;
    home = "/home/dvcorreia";
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel" # enable ‘sudo’ for the user
    ];
    shell = pkgs.zsh;
  };

  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      monaspace
      jetbrains-mono
      mononoki
      #nerdfonts.deja-vu-sans-mono
    ];
  };
}
