{
  config,
  inputs,
  pkgs,
  ...
}:
{
  age.rekey = {
    hostPubkey = inputs.self.sshKeys.${config.networking.hostName};
    masterIdentities = [ ../secrets/security-key-identity.pub ];
    agePlugins = [ pkgs.age-plugin-fido2-hmac ];
    storageMode = "local";
    localStorageDir = inputs.self.outPath + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
