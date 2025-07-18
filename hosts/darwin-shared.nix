{
  currentSystemUser,
  inputs,
  config,
  pkgs,
  ...
}:

let
  inherit (inputs.self) nixosModules;

  wallpaper = ./wallpaper.jpg;
in
{
  imports = [
    nixosModules.darwin-system
    nixosModules.darwin-nix
  ];

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system.primaryUser = currentSystemUser;

  # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
  system.activationScripts.postActivation.text = ''
    # setup desktop wallpaper
    sudo -u "${currentSystemUser}" osascript -e '
      set desktopImage to POSIX file "${wallpaper}"
      tell application "Finder"
        set desktop picture to desktopImage
      end tell
    '

    # activateSettings -u will reload the settings from the database and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  system.defaults.dock.persistent-apps = [
    "/Applications/Safari.app"
    "/Applications/Google Chrome.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/Applications/NetNewsWire.app"
    "/Applications/Spotify.app"
    "/Applications/Telegram.app"
    "/Applications/Discord.app"
  ];
}
