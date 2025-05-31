# dvcorreia/nix-config

Repo contains configuration for personal machines.

| Hostname            | OS            | Description                                              | Specifications                                                                                         |
| ------------------- | ------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `macbook-m3-pro`    | MacOS Sequoia | My precious personal laptop                              | Macbook Pro 14" 2023 w/ M3 Pro CPU 36GB RAM and 1TB SSD                                                |
| `macbook-pro-intel` | MacOS Sonoma  | Backup college laptop that also helps me test x86 things | Macbook Pro 13" 2018 w/ 2.3 GHz Quad-core Intel i5 CPU 8GB LPDDR3 RAM and 256GB SSD                    |
| `proart-7950x`      | NixOS         | Desktop computer that surely will be a server someday    | ProArt X670E-Creator WiFi motherboard w/ AMD 7950x 2x32GB 6000MHz CL30 RAM and 1TB SDD Samsung 990 Pro |

And a few others like:

- `wsl` target for setting my NixOS configuration in Windows WSL
- Home manager configurations for `dvcorreia` accross different systems

## Bootstrap a system

First and foremost, you will need to [install Nix](https://nixos.org/download/#nix-install-macos).

> [!NOTE]
> If your distro has selinux enabled by default, Nix will warn you about not supporting it.
> Turn if off by setting `SELINUX=disabled` in `/etc/selinux/config`.

### Darwin

```console
nix-shell
sudo bootstrap-darwin-system <hostname>
```

### Home Manager

```console
nix-shell
sudo bootstrap-home-manager <username>
```

## References

- https://github.com/MatthewCroughan/nixcfg
- https://github.com/mitchellh/nixos-config
- https://github.com/redyf/nixdots
