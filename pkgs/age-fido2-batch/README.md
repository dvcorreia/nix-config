# age-fido2-batch

Decrypts multiple age files with a FIDO2 identity using a **single unlock** —
one PIN prompt and one touch for the whole batch.

```
age-fido2-batch IDENTITY OUTPUT_DIR NAME FILE [NAME FILE ...]
```

Each `FILE` is decrypted to `OUTPUT_DIR/NAME` (mode `0600`). Outputs are
created exclusively and removed again if any decryption fails: a failed batch
never leaves partial secrets behind and never overwrites existing files.

The package is an `overrideAttrs` on nixpkgs'
[age-plugin-fido2-hmac](https://github.com/olastor/age-plugin-fido2-hmac) that
injects the sources under [`upstream/`](./upstream) into the build. It tracks
the nixpkgs pin, so there is nothing to maintain here beyond the injected
files.

## Why it exists

The devshell in this flake decrypts the OpenTofu secrets on entry through
[agenix-shell](https://github.com/aciceri/agenix-shell), which runs one
`age -d` process per secret. The age plugin protocol has no bulk mode — a
fresh plugin process is spawned per file (see
[olastor/age-plugin-fido2-hmac#15](https://github.com/olastor/age-plugin-fido2-hmac/issues/15)) —
so with a FIDO2 identity, entering the shell cost one PIN prompt and one touch
**per secret**.

`age-fido2-batch` decrypts all files in a single process instead. The first
stanza unwrap loads the secret from the token; the identity then caches it, so
every remaining file decrypts without further interaction. This only works for
version-2 identities: their HMAC salt is fixed in the identity, so one secret
unwraps every file. Version-1 identities carry the salt per stanza and would
still touch per file.

## Migrating existing secrets to a FIDO2 identity

Re-encrypting secrets does not need this tool — encryption to a version-2
recipient is native X25519 (the recipient string embeds the public key), so it
never touches the token. `age-fido2-batch` only speeds up the *verification*
step: checking that every new ciphertext decrypts correctly costs a single
unlock instead of one per secret.

Assuming secrets encrypted to an old SSH identity (classic agenix with
`secrets.nix`) and a version-2 split identity file (`identity.pub`, generated
once with `age-plugin-fido2-hmac -g`):

```bash
RECIPIENT=$(awk '/^# public key: / { print $4 }' identity.pub)
OLD=~/.ssh/id_ed25519   # identity that decrypts the current secrets

# 1. Re-encrypt every secret. Decryption uses the old identity and
#    encryption needs no token, so this loop runs unattended —
#    practical even for hundreds of secrets.
mkdir -m 700 reencrypted
for f in *.age; do
  age -d -i "$OLD" "$f" | age -r "$RECIPIENT" -o "reencrypted/$f"
done

# 2. Verify every new ciphertext against the original plaintext with one
#    PIN/touch for the whole batch.
pairs=()
for f in *.age; do pairs+=("$f" "reencrypted/$f"); done
mkdir -m 700 verified
age-fido2-batch identity.pub verified "${pairs[@]}"
for f in *.age; do
  cmp <(age -d -i "$OLD" "$f") "verified/$f" || exit 1
done

# 3. Replace the originals and clean up the plaintext copies.
mv reencrypted/*.age .
rm -r reencrypted verified
```

With [agenix-rekey](https://github.com/oddlama/agenix-rekey), finish by
regenerating the per-host copies (`agenix rekey`) and removing the old
`secrets.nix` rules.

Bulk-*creating* secrets is the same observation: encryption never touches the
token, so any number of new secrets is a plain loop:

```bash
for f in plain/*.txt; do
  name=$(basename "${f%.*}")
  [[ -e "$name.age" ]] || age -r "$RECIPIENT" -o "$name.age" "$f"
done
```

## Upstream landscape

- [olastor/age-plugin-fido2-hmac#15 — Is it possible to cache the PIN?](https://github.com/olastor/age-plugin-fido2-hmac/issues/15)
  The maintainer explains the per-file plugin process limitation and floats an
  `--export-x25519-identity` flag (exporting the derived key for the user to
  handle securely), but is not fond of exposing the unprotected key.
- [olastor/age-plugin-fido2-hmac#53 — Add command-scoped FIDO2 HMAC sessions](https://github.com/olastor/age-plugin-fido2-hmac/pull/53)
  An alternative design for the same problem: an
  `age-plugin-fido2-hmac-session` wrapper plus a Unix-socket broker that keeps
  the derived version-2 secret in locked memory for a wrapped command's
  lifetime, so repeated `age -d` invocations inside it reuse the unlock. The
  maintainer reacted positively (July 2026), but the PR is still open with CI
  pending approval.
- [aciceri/agenix-shell#50 — Find out how agenix-rekey works and if can work together with agenix-shell](https://github.com/aciceri/agenix-shell/issues/50)
  The other half of the local workaround: `flake.nix` injects
  `age-fido2-batch` into agenix-shell by overriding the internal
  `_installSecret` option via `mkOption.apply`. A proper batch-install hook in
  agenix-shell would replace that hack.

## Relationship to PR #53

Same problem, different shape. #53 enables **cross-process** reuse via a
socket broker; `age-fido2-batch` is **single-process** and needs no broker,
capability handshake, or cache lifetime management. If #53 merges, this tool
becomes unnecessary for the devshell use case — wrapping the shell hook with
`age-plugin-fido2-hmac-session` achieves the same single-unlock behavior — and
this package should be dropped in favor of it.

## Proposing upstream

The [`upstream/`](./upstream) tree mirrors the age-plugin-fido2-hmac repo
layout, so a PR is a subtree copy:

1. Comment on
   [#53](https://github.com/olastor/age-plugin-fido2-hmac/pull/53) first to
   avoid duplicating effort; if the session approach merges, prefer it (see
   above) instead of proposing this tool.
2. Otherwise, copy `upstream/cmd/age-fido2-batch/` into a fork of
   [age-plugin-fido2-hmac](https://github.com/olastor/age-plugin-fido2-hmac),
   add the binary to the `Makefile` build/clean targets (as #53 does for the
   session command), and open a PR.

Style notes borrowed from #53, to ease review: exit-code discipline (usage
errors exit `2`), doc comments explaining *why* (single-process reuse,
version-2-only restriction, atomic outputs), and table-driven subtests. #53
also added a `GetHmacSecretCalls` counter to `plugin.MockFido2Device`; the
`countingDevice` wrapper in `batch_test.go` exists only because the nixpkgs
pin predates it and can be dropped once that lands.
