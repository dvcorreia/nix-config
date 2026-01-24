{
  config,
  lib,
  ...
}:

let
  inherit (lib) types strings;
  cfg = config.system.defaults.wallpaper;

  supportedImageFileTypes = [
    "jpg"
    "jpeg"
    "png"
    "heic"
  ];

  fileTypesString = strings.concatStringsSep ", " (
    map (type: "\\\"${type}\\\"") supportedImageFileTypes
  );

  setWallpaperFromFile = ''
    tell application "Finder"
      set desktop picture to (POSIX file "${cfg.file}") as alias
    end tell
  '';

  setRandomWallpaperFromDir = ''
    tell application "Finder"
      set wallpaperDir to (POSIX file "${cfg.directory}") as alias
      set wallpapers to (every file of wallpaperDir whose name extension is in {${fileTypesString}})
      if (count of wallpapers) > 0 then
        set desktop picture to (some item of wallpapers) as alias
      end if
    end tell
  '';

  wallpaperScript =
    lib.optionalString (cfg.directory != null) setRandomWallpaperFromDir
    + lib.optionalString (cfg.file != null) setWallpaperFromFile;
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
        '';
      };

      directory = lib.mkOption {
        type = types.nullOr types.path;
        default = null;
        example = ./wallpapers;
        description = ''
          Path to a directory containing wallpaper images. A random image will
          be selected from this directory each time the activation script runs.
          Setting `system.defaults.wallpaper.file` overwrites this configuration.
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

      period = lib.mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
        example = 3600;
        description = ''
          Change wallpaper every N seconds. A directory must be specified for rotation.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.file != null || cfg.directory != null) {
    # activationScripts are executed every time you boot the system or run `darwin-reload`.
    system.activationScripts.postActivation.text = ''
      sudo -u "${cfg.user}" osascript -e '${wallpaperScript}'

      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    services.launchd.agents.wallpaper-rotator = lib.mkIf (cfg.period != null && cfg.directory != null) {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "sudo -u ${cfg.user} osascript -e '${wallpaperScript}' && /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u"
        ];
        StartInterval = cfg.period;
      };
    };
  };
}
