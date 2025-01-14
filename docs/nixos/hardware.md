Hardware modules are used to configure NixOS for well known hardware.

We expect only one hardware module to be imported per NixOS configuration.

Here are some of the hardwares that are supported:

### `nixosModules.hardware-amazon`

Hardware configuration for <https://aws.amazon.com/ec2> instances.

The main difference here is that the default userdata service is replaced by cloud-init.

### `nixosModules.hardware-hetzner-cloud`

Hardware configuration for <https://www.hetzner.com/cloud> instances.

The main difference here is that cloud-init is enabled.

### `nixosModules.hardware-hetzner-online-amd`

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal AMD servers.

Introduces some workaround for the perticular IPv6 configuration that Hetzner has.

### `nixosModules.hardware-hetzner-online-intel`

Hardware configuration for <https://www.hetzner.com/dedicated-rootserver> bare-metal Intel servers.

Introduces some workaround for the perticular IPv6 configuration that Hetzner has.