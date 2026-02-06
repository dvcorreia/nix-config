# dvcorreia/nix-config

Repo contains configuration for personal machines.

| Hostname            | OS            | Description                                              | Specifications                                                                                         |
| ------------------- | ------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `macbook-m3-pro`    | MacOS Sequoia | My precious personal laptop                              | Macbook Pro 14" 2023 w/ M3 Pro CPU 36GB RAM and 1TB SSD                                                |
| `proart-7950x`      | NixOS         | Desktop computer that surely will be a server someday    | ProArt X670E-Creator WiFi motherboard w/ AMD 7950x 2x32GB 6000MHz CL30 RAM and 1TB SDD Samsung 990 Pro |
| `sines`             | NixOS         | Hetzner server used as my internet entrypoint            | Hetzner CX23 at the Helsinki datacenter                                                                |

And a few others like:

- `wsl` target for setting my NixOS configuration in Windows WSL
- Home manager configurations for `dvcorreia` accross different systems

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

### WSL

Follow the instructions in the [NixOS WSL documentation](https://nix-community.github.io/NixOS-WS), with special attention to [how-to/change-username](https://nix-community.github.io/NixOS-WSL/how-to/change-username.html).

### Home Manager

```console
nix-shell
sudo bootstrap-home-manager <username>
```

Then, you will be able to switch generations with:

```console
home-manager switch --flake .
```

## Manage Infrastructure

Enter the infrastructure development shell environment:

> [!NOTE]
> Be sure you are in a machine with SSH keys capable of decrypt the secrets.

```bash
nix develop .#infra -c $SHELL
```

All OpenTofu operations live in the `terraform/` directory.
We make use of the plan and state encryption feature, so no remote backend is needed.

```bash
tofu init
tofu plan
tofu apply
```

This initializes, provisions or updates the required infrastructure resources.

### Setup NixOS Server

After adding the required Terraform resources and apply the changes, bootstrap the server using [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#target-nixos-config \
  --target-host "root@target-ipv4-address" \
  --build-on remote
```

This installs NixOS on the target machine using the specified flake configuration.

To then update the configuration, run:

```bash
nixos-rebuild switch \
  --flake .#target-nixos-config \
  --target-host "root@target-ipv4-address" \
  --build-host "root@target-ipv4-address" \
  --fast
```

## To Explore

Here is a set of things I want to explore:

- MacOS linux-build rosetta integration: this is still ongoing last time I checked. Here is a [good read](https://nixcademy.com/posts/macos-linux-builder/) on the linux-build.

## References

- https://github.com/MatthewCroughan/nixcfg
- https://github.com/mitchellh/nixos-config
- https://github.com/fzakaria/nix-home
- https://github.com/Misterio77/nix-starter-configs
- https://github.com/redyf/nixdots
- https://github.com/oddlama/nix-config
- https://git.jolheiser.com/infra
