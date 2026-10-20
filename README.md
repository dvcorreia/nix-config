# dvcorreia/nix-config

Repo contains configuration for personal machines.

| Hostname            | OS            | Description                                   | Specifications                                                                                         |
| ------------------- | ------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `macbook-m3-pro`    | MacOS Tahoe   | My precious personal laptop                   | Macbook Pro 14" 2023 w/ M3 Pro CPU 36GB RAM and 1TB SSD                                                |
| `proart-7950x`      | NixOS         | Server at my parents home                     | ProArt X670E-Creator WiFi motherboard w/ AMD 7950x 2x32GB 6000MHz CL30 RAM and 1TB SSD Samsung 990 Pro |
| `sines`             | NixOS         | Hetzner server used as my internet entrypoint | Hetzner CX23 at the Helsinki datacenter                                                                |
| `rpi3b-home`        | NixOS (ARM)   | Raspberry Pi 3B+ I have at home               | Broadcom BCM2837B0 (aarch64), 1GB RAM, booting from SD card                                            |

## Bootstrap PC

First and foremost, if you are not using NixOS
you will need to [install Nix](https://nixos.org/download/).

> [!NOTE]
> If your Linux distro has selinux enabled by default, Nix will warn about not supporting it.
> Turn it off by setting `SELINUX=disabled` in `/etc/selinux/config`.

### Darwin

```console
nix-shell
sudo bootstrap-darwin-system <hostname>
```

## Manage Infrastructure

Enter the infrastructure development shell environment:

> [!NOTE]
> Connect the Security Key used by `secrets/security-key-identity.pub`.
> Entering the shell prompts for its PIN and touch to decrypt the OpenTofu secrets.

```bash
nix develop
```

All [OpenTofu](https://opentofu.org) operations live in the `terraform/` directory.
We make use of the plan and state encryption feature, so no remote backend is needed.

```bash
tofu init
tofu plan
tofu apply
```

This initializes, provisions or updates the required infrastructure resources.

### Secrets

Repository secrets are encrypted to the FIDO2 master identity. With the Security
Key connected, use the devshell to edit a secret and update its host copies:

```bash
agenix edit secrets/<name>.age
agenix rekey
git add secrets/
```

Commit both the master ciphertext and generated copies in `secrets/rekeyed/`
before deploying. Hosts declare secrets with `age.secrets.<name>.rekeyFile` and
decrypt their copies using their own SSH host keys.

The OpenTofu secrets remain master-only and are decrypted by `agenix-shell`.
Re-encrypting the stored state passphrase preserves its value; rotating that
passphrase requires an OpenTofu encryption fallback migration.

## Deploy

Deploy configurations to remote hosts using `deploy-rs`:

```bash
deploy .#sines
deploy .#proart-7950x
```

### Setup NixOS Server

After adding the required Terraform resources and apply the changes, bootstrap the server using [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#target-nixos-config \
  --target-host "root@target-ipv4-address" \
  --build-on remote
```

This installs NixOS on the target machine using the specified flake configuration.

To then update the configuration, use deploy-rs as described in the Deploy section above.

### Raspberry Pi

#### Bootstrap

Build a flashable, uncompressed SD card image:

```bash
nix build .#nixosConfigurations.rpi3b-home.config.system.build.sdImage
```

Flash it to the SD card (macOS). Use `diskutil list` to find the device first,
and double-check it before writing:

```bash
diskutil list
diskutil unmountDisk /dev/diskN
sudo dd if=result/sd-image/*.img of=/dev/rdiskN bs=1M status=progress
diskutil eject /dev/diskN
```

Boot the Pi (wired Ethernet, DHCP) and connect over SSH:

```bash
ssh root@rpi3b-home.local
```

> [!NOTE]
> After the first boot, capture the Pi's SSH host key into `secrets/ssh-keys.nix`
> so `agenix` can encrypt secrets to it once you start running services on it.

#### Update

From then on, iterate with `deploy-rs`:

```bash
deploy .#rpi3b-home
```

Builds are offloaded from the Mac to `proart-7950x` (which emulates
`aarch64-linux` via `boot.binfmt`), falling back to the Mac's local
`nix.linux-builder`. The Pi itself should never build anything.

## References

A set of other configurations that have inspired me:

- https://github.com/MatthewCroughan/nixcfg
- https://github.com/mitchellh/nixos-config
- https://github.com/fzakaria/nix-home
- https://github.com/Misterio77/nix-starter-configs
- https://github.com/redyf/nixdots
- https://github.com/oddlama/nix-config
- https://git.jolheiser.com/infra
