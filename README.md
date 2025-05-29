# dvcorreia/nix-config

Repo contains configuration for personal machines.

| Hostname            | OS            | Description                                              | Specifications                                                                                         |
| ------------------- | ------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `macbook-m3-pro`    | MacOS Sequoia | My precious personal laptop                              | Macbook Pro 14" 2023 w/ M3 Pro CPU 36GB RAM and 1TB SSD                                                |
| `macbook-pro-intel` | MacOS Sonoma  | Backup college laptop that also helps me test x86 things | Macbook Pro 13" 2018 w/ 2.3 GHz Quad-core Intel i5 CPU 8GB LPDDR3 RAM and 256GB SSD                    |
| `proart-7950x`      | NixOS         | Desktop computer that surely will be a server someday    | ProArt X670E-Creator WiFi motherboard w/ AMD 7950x 2x32GB 6000MHz CL30 RAM and 1TB SDD Samsung 990 Pro |

## Bootstrap a system

### Darwin

```console
# install nix
sh <(curl -L https://nixos.org/nix/install)

nix-shell
sudo bootstrap-darwin-system <hostname>
```

### WSL

Follow the instructions on [NixOS WSL documentation](https://nix-community.github.io/NixOS-WS), with special attention to [how-to/change-username](https://nix-community.github.io/NixOS-WSL/how-to/change-username.html).

## References

- https://github.com/MatthewCroughan/nixcfg
- https://github.com/mitchellh/nixos-config
- https://github.com/redyf/nixdots
