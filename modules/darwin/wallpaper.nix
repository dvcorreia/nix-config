{
  config,
  lib,
  ...
}:

let
  inherit (lib) types;
  cfg = config.system.defaults.wallpaper;
in
{
  options = {
    system.defaults.wallpaper = {
      file = lib.mkOption {
        type = types.nullOr types.path;
        default = null;
        example = ./wallpaper.jpg;
        description = ''
          Path to the wallpaper image file to set as the desktop background.
          Setting this option automatically enables the wallpaper service.
        '';
      };

      user = lib.mkOption {
        type = types.str;
        default = config.system.primaryUser;
        example = "john";
        description = ''
          The username for which to set the desktop wallpaper.
          Defaults to `system.primaryUser`.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.file != null) {
    # activationScripts are executed every time you boot the system or run `darwin-rebuild`.
    system.activationScripts.postActivation.text = ''
      # setup desktop wallpaper
      sudo -u "${cfg.user}" osascript -e '
        set desktopImage to POSIX file "${cfg.file}"
        tell application "Finder"
          set desktop picture to desktopImage
        end tell
      '

      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };
}
