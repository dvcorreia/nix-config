{ pkgs, inputs }:

pkgs.testers.nixosTest {
  name = "dvcorreia-website";
  nodes.server = {
    _module.args.inputs = inputs;
    imports = [ ../hosts/sines/websites/dvcorreia_com.nix ];
    services.nginx.enable = true;
    networking.firewall.allowedTCPPorts = [ 80 ];
    security.acme = {
      acceptTerms = true;
      defaults.email = "test@example.com";
    };
  };
  testScript = ''
    server.start()
    server.wait_for_unit("nginx.service")
    server.wait_for_open_port(80)
    server.succeed("curl -sSf http://localhost/index.html | grep -q 'dvcorreia'")
  '';
}
