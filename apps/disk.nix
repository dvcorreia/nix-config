# Format a NAS data disk over SSH: builds a one-shot disko config for the
# device, copies it to the target, and runs disko there — pinned to the locked
# disko revision so formatting never depends on a moving ref.
#
#   nix run .#disk -- root@nas.dvcorreia.loc /dev/disk/by-id/ata-XYZ disk2
#
# Works from the NixOS installer too (bootstrap): pass the installer's address
# and the `disk1` label.
{
  pkgs,
  diskoRef,
}:

{
  type = "app";
  program = "${
    pkgs.writeShellApplication {
      name = "disk";
      runtimeInputs = [ pkgs.openssh ];
      text = ''
        set -euo pipefail

        usage() {
          echo "usage: nix run .#disk -- <ssh-target> <device-by-id> <label>"
          echo "example: nix run .#disk -- root@nas.dvcorreia.loc /dev/disk/by-id/ata-ST2000VN004-2E4164_Z520JGYH disk2"
          exit 1
        }

        [ "$#" -eq 3 ] || usage
        target="$1"
        device="$2"
        label="$3"

        case "$device" in
          /dev/disk/by-id/*) ;;
          *)
            echo "error: device must be a stable /dev/disk/by-id/... path, got: $device" >&2
            exit 1
            ;;
        esac

        if [ -z "$label" ] || ! [[ "$label" =~ ^[A-Za-z0-9_-]+$ ]]; then
          echo "error: label must be alphanumeric (e.g. disk2, parity), got: $label" >&2
          exit 1
        fi

        echo "This DESTROYS all data on:"
        echo "  host:   $target"
        echo "  device: $device"
        echo "  label:  $label (mounted at /mnt/$label after deploy)"
        echo
        read -r -p "Type the label to confirm: " confirm
        if [ "$confirm" != "$label" ]; then
          echo "aborted" >&2
          exit 1
        fi

        tmp="$(mktemp -d)"
        trap 'rm -rf "$tmp"' EXIT
        config="$tmp/disko-$label.nix"

        # One filesystem per disk, labelled so hosts/nas/storage.nix can mount
        # by label without ever holding a device path.
        cat >"$config" <<EOF
        {
          disko.devices = {
            disk = {
              "$label" = {
                device = "$device";
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    data = {
                      size = "100%";
                      content = {
                        type = "filesystem";
                        format = "ext4";
                        extraArgs = [ "-L" "$label" ];
                        mountpoint = "/mnt/$label";
                      };
                    };
                  };
                };
              };
            };
          };
        }
        EOF

        scp "$config" "$target:/tmp/"
        ssh "$target" nix run "${diskoRef}" -- --mode format "/tmp/disko-$label.nix"

        echo
        echo "Formatted $device as '$label'. Next:"
        echo "  1. append \"$label\" to disks in hosts/nas/storage.nix"
        echo "  2. deploy --skip-checks .#nas"
      '';
    }
  }/bin/disk";
}
