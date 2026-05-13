{
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs.self) sshKeys;
  inherit (config.networking) hostName;
in
{
  assertions = [
    {
      assertion = hostName != null;
      message = "agenix-rekey: networking.hostName is not set.";
    }
    {
      assertion = builtins.hasAttr hostName sshKeys;
      message = "agenix-rekey: no SSH key found in sshKeys for host '${hostName}'.";
    }
  ];

  age.rekey = {
    hostPubkey = sshKeys.${hostName};
    masterIdentities = [ ../secrets/yubikey1.pub ];
    agePlugins = [ pkgs.age-plugin-fido2-hmac ];
    storageMode = "local";
    localStorageDir = ../. + "/secrets/rekeyed/${hostName}";
  };
}
