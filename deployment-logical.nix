{
  machine-name = {pkgs, ...}:
  {
    services.nginx = {
      enable = true;
      virtualHosts."virtualHosty" = {
        default = true; 
        locations."/" = {
          root = pkgs.writeTextDir "index.html" "Hello world!";
        };
      };
    };
    # NB: port 22 is already open in `configuration.nix` of the initial NixOS AMI 
    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
