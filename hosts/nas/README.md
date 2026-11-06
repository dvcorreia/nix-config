# nas

Home NAS following the [Perfect Media Server](https://perfectmediaserver.com/)
model: one filesystem per disk, pooled with `mergerfs`, with SnapRAID parity
once a parity disk exists. Data lives in the pool at `/mnt/storage`.

The boot SSD is managed by `disko`. Data disks are formatted out-of-band with
`nix run .#disk` and never declared in any imported disko config, so
reinstalling NixOS can never wipe them.

## Operations

## Add a data disk

1. Format the disk (destructive):

   ```bash
   nix run .#disk -- root@nas.dvcorreia.loc /dev/disk/by-id/<disk-id> disk2
   ```

2. Append `"disk2"` to `disks` in [`storage.nix`](storage.nix).
3. Deploy: `deploy --skip-checks .#nas` — the disk is mounted by label and
   joins the `/mnt/storage` pool automatically.

## Enable SnapRAID parity

1. Format a disk at least as large as the biggest data disk:

   ```bash
   nix run .#disk -- root@nas.dvcorreia.loc /dev/disk/by-id/<disk-id> parity
   ```

2. Set `parity = "parity";` in [`storage.nix`](storage.nix).
3. Deploy: `deploy --skip-checks .#nas`.

## Samba

The `storage` share is served from `/mnt/storage`. Samba passwords are not
declarative in NixOS 26.05, so create the user once:

```bash
ssh root@nas.dvcorreia.loc 'chown dvcorreia:users /mnt/disk1 && smbpasswd -a dvcorreia'
```
