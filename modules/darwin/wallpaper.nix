{
  currentSystemUser,
  ...
}:

let
  wallpaper = ./wallpaper.jpg;
in
{
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
}
