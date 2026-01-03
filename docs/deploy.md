# Infrastructure Management

Enter the infrastructure development shell environment:

> [!NOTE]
> Be sure you are in a machine with SSH keys capable of decrypt the secrets.

```bash
nix develop .#infra -c $SHELL
```

## OpenTofu Workflow

All OpenTofu operations live in the `terraform/` directory.
We make use of the plan and state encryption feature, so no remote backend is needed.

```bash
tofu init
tofu plan
tofu apply
```

This initializes, provisions or updates the required infrastructure resources.

## Provisioning a NixOS Server

1. Add or update the required Terraform resources.
2. Apply the Terraform changes.
3. Bootstrap the server using [`nixos-anywhere`](https://github.com/nix-community/nixos-anywhere):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#target-nixos-config \
  --target-host "root@$(cd terraform && tofu output --raw target_machine_ipv4)" \
  --build-on remote
```

This installs NixOS on the target machine using the specified flake configuration.
You will probably need you Yubikey for this.

## Update a NixOS Server

```bash
nixos-rebuild switch \
  --flake .#target-nixos-config \
  --target-host "root@$(cd terraform && tofu output --raw target_machine_ipv4)" \
  --build-host "root@$(cd terraform && tofu output --raw target_machine_ipv4)" \
  --use-remote-sudo \
  --fast
```
