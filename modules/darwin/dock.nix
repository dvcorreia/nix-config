_: {
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.0;

    mru-spaces = false;
    orientation = "bottom";
    showhidden = true;
    tilesize = 44;
    mineffect = "scale";
    persistent-apps = [
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
    show-recents = false;

    wvous-tl-corner = 2; # top-left - Mission Control
    wvous-tr-corner = 1; # top-right - Does nothing (13 for Lock Screen)
    wvous-bl-corner = 3; # bottom-left - Application Windows
    wvous-br-corner = 4; # bottom-right - Desktop
  };
}
