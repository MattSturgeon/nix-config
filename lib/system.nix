{
  util,
  lib,
  inputs,
  outputs,
  ...
}: let
  inherit (builtins) length attrValues;
  inherit (lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (util.user) mkNixOSUserModule mkHMUserModule mkNixOSHMModule getHomeConfig;

  # Platform to use when system is not provided
  defaultSystem = "x86_64-linux";

  # Include all inputs in specialArgs;
  # now we don't have to overlay stuff into nixpkgs
  specialArgs =
    inputs
    // {
      inherit inputs outputs util;
    };

  # Build a NixOS config, including Home Manager configs for any hmUsers specified
  mkNixOSConfig = {
    hostname,
    system ? defaultSystem,
    users ? [],
    hmUsers ? [],
  }:
    nixosSystem {
      inherit system specialArgs;
      modules =
        [
          ../hosts/${hostname}/configuration.nix
          ../hosts/${hostname}/hardware-configuration.nix
          (mkNixOSUserModule (users ++ hmUsers))
          {
            networking.hostName = hostname;
          }
        ]
        ++ (attrValues outputs.nixosModules)
        ++ (
          if (length hmUsers) == 0
          then []
          else [
            inputs.home-manager.nixosModules.home-manager
            (mkNixOSHMModule ../hosts/${hostname} hmUsers)
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = attrValues outputs.homeManagerModules;
            }
          ]
        );
    };

  # Builds a standalone Home Manager config, independent of NixOS
  mkHMConfig = {
    hostname,
    user,
    system ? defaultSystem,
  }:
    homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs;
      modules =
        (attrValues outputs.homeManagerModules)
        ++ [
          (mkHMUserModule user)
          (getHomeConfig ../hosts/${hostname} user.name)
        ];
    };
in {
  # Global aliases
  inherit mkNixOSConfig mkHMConfig;

  system = {
    inherit mkNixOSConfig mkHMConfig defaultSystem;
  };
}
