{ currentSystem, pkgs, ... }:

{
  programs.ghostty = {
    enable = currentSystem != "aarch64-linux";

    package = if !pkgs.stdenv.isDarwin then pkgs.unstable.ghostty else null;

    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "dark:Aizen Dark,light:Aizen Light";
      font-thicken = pkgs.stdenv.isDarwin;
      window-padding-x = 8;
      window-padding-y = 4;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = "auto";
      window-theme = "system";

      macos-secure-input-indication = false;
    };
  };
}
