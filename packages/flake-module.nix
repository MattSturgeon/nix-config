{ lib, self, ... }:
{
  perSystem =
    { config, pkgs, ... }:
    {
      packages = {
        update-modrinth-lock = pkgs.callPackage ./update-modrinth-lock/wrapper.nix {
          inherit (config.packages) update-modrinth-lock-unwrapped;
          nixosConfigs = lib.attrValues self.nixosConfigurations;
        };
        update-modrinth-lock-unwrapped = pkgs.callPackage ./update-modrinth-lock { };
      };
    };
}
