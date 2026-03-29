{ config, ... }:

{
  age.secrets.deploy-ssh-key = {
    file = ../../secrets/deploy-ssh-key.age;
    owner = "deploy";
    group = "deploy";
    mode = "0400";
    path = "/var/lib/deploy/.ssh/id_ed25519";
  };
}
