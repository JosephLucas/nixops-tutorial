let 
  accessKeyId = "dev"; # select AWS credentials from ~/.ec2-keys
  region = "eu-west-1"; # FIXME : "eu-west-3" (Paris) does not work for unknow reason
in {

  network.description = "Description of the network";

  ## Provisioning 
  ## NB : provisionned items are specific to a region and an accessKeyId
  ### A ssh keypair
  resources.ec2KeyPairs.key-pair-name = { inherit region accessKeyId; };
  ### Security groups (i.e. firewall rules at the EC2 level)
  resources.ec2SecurityGroups.allow-ssh = {
    inherit accessKeyId region;
    description = "Allow ssh from/to any ip";
    rules = [ { fromPort = 22; toPort = 22; sourceIp = "0.0.0.0/0"; } ]; 
  };
  resources.ec2SecurityGroups.allow-http = {
    inherit accessKeyId region;
    description = "Allow http from/to any ip";
    rules = [ { fromPort = 80; toPort = 80; sourceIp = "0.0.0.0/0"; } ]; 
  };

  machine-name = { resources, pkgs, ... }:
  { 
    ## Physical
    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit accessKeyId region;
        instanceType = "t2.micro";
        # Upload the provisionned public ssh key
        keyPair = resources.ec2KeyPairs.key-pair-name;
        # Use provisionned security groups.
        # The security group allowing ssh is really necessary. 
        # FIXME : impossible to use the "default" security group.
        securityGroups = [ resources.ec2SecurityGroups.allow-ssh resources.ec2SecurityGroups.allow-http ]; 
      };
    };

    ## Logical
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

