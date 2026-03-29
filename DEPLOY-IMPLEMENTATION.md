# deploy-rs Implementation Status

## Overview

Implementing deploy-rs for automated NixOS deployments with:
- Manual deployment via `nix run .#deploy`
- CI/CD auto-deployment on push to main
- Dedicated `deploy` user with SSH key authentication
- Auto-rollback enabled

## Architecture

```
proart-7950x (self-hosted runner)
├── Builds all NixOS configs
├── Holds deploy SSH private key (agenix encrypted)
└── Deploys to:
    ├── proart-7950x (localhost, via deploy user → sudo to root)
    └── sines (remote, via deploy user → sudo to root)
```

## Current Status

### Completed

- [x] Added deploy-rs input to `flake.nix`
- [x] Created `modules/nixos/deploy-user.nix` module
- [x] Updated hosts to import deploy-user module
- [x] Added deploy output and deployChecks to flake.nix
- [x] Updated GitHub Actions workflow with deploy job
- [x] Updated README with deployment docs
- [x] Generated SSH key pair for deploy user

### Blocked - Requires Manual Action

- [ ] **Create `secrets/deploy-ssh-key.age`** - The agenix-encrypted private key

## SSH Key Details

**Public key** (already configured in `modules/nixos/deploy-user.nix`):
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKURVu1hE+aKAK/O8rB1hEbmQ18fPokpit5JeREtrqOQ deploy@proart-7950x
```

**Private key** (needs to be encrypted):
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACClEVbtYRPmigCvzvKwdYRG5kNfHz6JKYreSXkRLa6jkAAAAJjcUR783FEe
/AAAAAtzc2gtZWQyNTUxOQAAACClEVbtYRPmigCvzvKwdYRG5kNfHz6JKYreSXkRLa6jkA
AAAEC0N833tWRwKU5R7tekn+mBDd5NJK5sNUW51VpEZnEwRKURVu1hE+aKAK/O8rB1hEbm
Q18fPokpit5JeREtrqOQAAAAE2RlcGxveUBwcm9hcnQtNzk1MHgBAg==
-----END OPENSSH PRIVATE KEY-----
```

## Steps to Complete

### 1. Encrypt the SSH key with agenix

```bash
cd /Users/dvcorreia/projects/nix-config/secrets
nix shell github:ryantm/agenix -c agenix -e deploy-ssh-key.age
```

Paste the private key content above into the editor, save and exit.

### 2. Add the encrypted file to git

```bash
git add secrets/deploy-ssh-key.age
```

### 3. Verify flake builds

```bash
nix flake check --no-build
```

### 4. First deployment

Deploy to proart-7950x first (localhost):
```bash
nix run .#deploy -- .#proart-7950x
```

Then deploy to sines:
```bash
nix run .#deploy -- .#sines
```

## Files Modified

| File | Change |
|------|--------|
| `flake.nix` | Added deploy-rs input, deploy.nodes, deployChecks |
| `modules/nixos/deploy-user.nix` | New: deploy user with SSH key, sudo access |
| `hosts/proart-7950x/configuration.nix` | Import deploy-user module |
| `hosts/proart-7950x/deploy.nix` | New: agenix secret for SSH key |
| `hosts/sines/configuration.nix` | Import deploy-user module |
| `secrets/secrets.nix` | Added deploy-ssh-key.age entry |
| `secrets/deploy-ssh-key.age` | **TODO**: Create this file |
| `.github/workflows/system.yaml` | Added deploy job after linux builds |
| `README.md` | Added deployment documentation |

## Key Configuration Details

### deploy-rs node config (flake.nix)

```nix
deploy.nodes = {
  proart-7950x = {
    hostname = "proart-7950x";
    sshUser = "deploy";
    user = "root";
    profiles.system = {
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.proart-7950x;
    };
  };
  sines = {
    hostname = "sines.dvcorreia.com";
    sshUser = "deploy";
    user = "root";
    profiles.system = {
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.sines;
    };
  };
};
```

### deploy user sudo config (modules/nixos/deploy-user.nix)

- User: `deploy`
- Home: `/var/lib/deploy`
- SSH authorized_keys: deploy public key
- Sudo: NOPASSWD ALL (deploy-rs needs root access for activation)

### GitHub Actions deploy job

- Runs after successful linux builds
- Only on push to main (not PRs)
- Uses SSH key from `/var/lib/deploy/.ssh/id_ed25519` (decrypted by agenix)
- Runs `nix run .#deploy`

## Security Model

- Private SSH key encrypted with agenix, stored in repo
- Key decrypted only on proart-7950x (has the age key)
- deploy user can sudo to root (required by deploy-rs)
- Auto-rollback enabled to prevent lockouts
- macOS (macbook-m3-pro) does NOT auto-deploy

## Manual Deployment Commands

```bash
# Deploy all hosts
nix run .#deploy

# Deploy specific host
nix run .#deploy -- .#sines

# Dry-run (no changes)
nix run .#deploy -- --dry-activate

# Debug
nix run .#deploy -- --debug
```

## References

- [deploy-rs README](https://github.com/serokell/deploy-rs)
- [deploy-rs security model](https://github.com/serokell/deploy-rs#magic-rollback)
