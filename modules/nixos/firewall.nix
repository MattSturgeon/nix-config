{ inputs, ... }:
{
  imports = [
    inputs.firewalld-nix.nixosModules.default
  ];

  # Use firewalld for dynamic firewall zones that integrate well with networkmanager.
  services.firewalld.enable = true;
}
