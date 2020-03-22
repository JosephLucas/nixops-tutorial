# HOWTO deploy a "hello world!" NGINX http server using NixOps

## Install nixops

```
nix-env -iA nixos.nixops
```

## Create an AWS account 

We will use one of the Amazon Web Services (AWS) named Elastic Compute Cloud (EC2), dedicated to provision virtual servers for calculations.

1. Create an account at https://aws.amazon.com/resources/create-account/. 
   You will be asked for payment details even if you just want to use the AWS Free Tier offer. 
   AWS Free Tier includes 750 hours of Linux and Windows "t2.micro" instances each month for one year.
2. In your AWS Management Console, click on your username (top-right). 
   Then go to `My Security Credentials > Access keys > Create New Access Key`. 
   Copy the file on your machine. 
   It contains the "AWS Access Key ID" and "AWS Secret Key" : a private/public key pair used to interact with AWS.
3. Create a file `~/.ec2-keys` with
   ```
   XXXXXXXXXXXXXXXXXXXXX  0xxxxxxxxx0000++xxxxxxxxxxxxxx dev # my AWS development account
   ```
   where "XXXXXXXXXXXXXXXXXXXXX" is your AWSAccessKeyID and "0xxxxxxxxx0000++xxxxxxxxxxxxxx" is your AWSSecretKey
4. `chmod 600 ~/.ec2-keys`


## Declare a deployment 

The `./deployment.nix` file declares an EC2 server with an NGINX server returning "Hello World!" to any HTTP request.

The underliyng NixOS EC2 AMI already has a `/etc/nixos/configuration.nix` file with 
```
{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true; # hvm : hardware assisted virtialisation
}
```
The `amazon-image.nix` Nix expression file already declares a GRUB bootloader, an ssh service with an open 22 port and some ad hoc disk configurations. 
See [amazon-image.nix on nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/amazon-image.nix) for more informations.

The `./deployment.nix` builds upon this foundation.

## Deploy

Create a deployment 
```
nixops create -d <deployment-name> deployment.nix
```
This adds a new entry in the state file `~/.nixops/deployments.nixops` (which is just a SQLite DB)

Deploy the instance
```
nixops deploy -d <deployment-name>
```

## Split the deployment declaration into a _physical_ and a _logical_ part

For convenience `./deployment.nix` can be split into `./deployment-physical.nix` and `./deployment-logical.nix`.

Create the deployment from merged Nix expressions with
```
nixops create -d <deployment-name> deployment-physical.nix deployment-logical.nix
```

## Test the deployment

Print some info about a deployment 
```
nixops info -d <deployment-name>
```
an easy way to get the public IP of the deployed instances.

Test the server
```
curl <IP>
```
It should return "Hello World!"

Ssh within the remote machine 
```
nixops ssh <machine-name>
```
In our case `<machine-name>` is "webservery".

Within the machine console, you can check the public IP
```
curl ifconfig.me
```

Look at the AWS Management Consol and check all created AWS items : instance, key pair, security groups, etc.

## Remove obsolete resources/machines

Get rid of obsolete resources or obsolete AWS machines, those that are no longer needed by all current deployments
```
nixops deploy --kill-obsolete
```

## Vocabulary

- *AMI* : Amazon Machine Image : "a special type of virtual appliance that is used to create a virtual machine within the Amazon EC2". 
   It serves as the basic unit of deployment for services delivered using EC2.

- *HVM* (qualifies an AMI): Hardware Virtual Machine. A fully virtualized set of hardware and boot. Whereas a *PV* AMI (para-virualised AMI) has "a special boot loader" (PV-GRUB). Paravirtual guests can run on host hardware that does not have explicit support for virtualization.

- "to provision" : mise à disposition, ravitaillement, approvisionnement, fourniture.

- "cloud provisioning" refers to how a customer procures cloud services and resources from a cloud provider.

- A "security group" acts as a virtual firewall that controls the traffic for one or more instances.

