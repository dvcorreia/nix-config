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
    CURR_HOSTNAME="$(scutil --get HostName 2> /dev/null || echo "")"
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

    # install rosetta 2
    if [ "$(arch)" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
      log "installing rosetta 2"
      softwareupdate --install-rosetta --agree-to-license
    else
      logskip "rosetta 2 installation"
    fi

    log "done, should be good to go"
  '';

  bootstrap-home-manager = pkgs.writeScriptBin "bootstrap-home-manager" ''
    #!/usr/bin/env bash
    set -euo pipefail

    log() { echo "--> $1"; }
    usage() {
      echo "usage: sudo bootstrap-home-manager <username>"
    }
    panic() { echo "error: $1! $(usage)" >&2; exit 1; }

    if [ $# -eq 0 ]; then
      panic "no username provided"
    fi

    USERNAME="$1"
    SYSTEM=$(nix eval --impure --raw --expr 'builtins.currentSystem')
    TARGET="''${USERNAME}@''${SYSTEM}"

    log "building home manager configuration for ''${TARGET}"
    nix run ".#homeConfigurations.\"''${USERNAME}@''${SYSTEM}\".activationPackage"

    # log "activating home manager configuration"
    # ./result/activate

    log "done, should be good to go"
    log "restart your shell or run 'exec ''${SHELL} -l'"
  '';
in
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.gnumake
    bootstrap-darwin-system
    bootstrap-home-manager
  ];

  shellHook = ''
    hr() {
      printf '%s\n' "$(printf '#%.0s' {1..45})"
    }

    hr
    echo "bootstrap a machine by running the appropriate script:"
    echo "$ sudo bootstrap-darwin-system <hostname>"
    echo "$ bootstrap-home-manager <username>"
    hr
  '';
}
