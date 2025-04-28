{
  pkgs ? import <nixpkgs> { },
}:

let
  bootstrap-darwin-system = pkgs.writeScriptBin "bootstrap-darwin-system" ''
    #!/usr/bin/env bash
    set -euo pipefail

    log() { echo "--> $1"; }
    logskip() { echo "skipped: $1"; }
    usage() {
      echo "usage: sudo bootstrap-darwin-system <hostname>"
    }
    panic() { echo "error: $1! $(usage)" >&2; exit 1; }

    # check for root privileges
    if [ "$(id -u)" -ne 0 ]; then
      panic "needs root privileges"
    fi

    if [ $# -eq 0 ]; then
      panic "no hostname provided"
    fi

    HOSTNAME="$1"

    # set the computer hostname
    CURR_HOSTNAME="$(scutil --get HostName 2> /dev/null)"
    if [ "$CURR_HOSTNAME" != "$HOSTNAME" ]; then
      log "setting hostname"
      scutil --set HostName "$HOSTNAME"
      scutil --set LocalHostName "$HOSTNAME"
      scutil --set ComputerName "$HOSTNAME"
    else
      logskip "setting hostname"
    fi

    # some brew packages depend on it
    if ! xcode-select -p &> /dev/null; then
      log "installing xcode command line tools"
      xcode-select --install
    else
      logskip "xcode command line tools"
    fi

    log "done, should be good to go"
  '';
in
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.gnumake
    bootstrap-darwin-system
  ];

  shellHook = ''
    hr() {
      printf '%s\n' "$(printf '#%.0s' {1..45})"
    }

    hr
    echo "to bootstrap a darwin machine, run:"
    echo "$ sudo bootstrap-darwin-system <hostname>"
    hr
  '';
}
