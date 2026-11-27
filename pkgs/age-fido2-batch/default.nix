{ age-plugin-fido2-hmac }:
age-plugin-fido2-hmac.overrideAttrs (old: {
  pname = "age-fido2-batch";
  subPackages = [ "cmd/age-fido2-batch" ];

  # upstream/ mirrors the age-plugin-fido2-hmac repo layout so it can be
  # proposed as a PR by copying it there; see ./README.md.
  postPatch = (old.postPatch or "") + ''
    cp -r ${./upstream}/cmd/age-fido2-batch cmd/age-fido2-batch
  '';

  meta = old.meta // {
    description = "Decrypt multiple age files with one FIDO2 identity unlock";
    mainProgram = "age-fido2-batch";
  };
})
