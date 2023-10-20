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

  defaultSystem = "x86_64-linux";

  # Include all inputs in specialArgs;
  # now we don't have to overlay stuff into nixpkgs
  specialArgs =
    inputs
    // {
      inherit inputs outputs util;
    };
in {
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
          # TODO generic modules? global config?
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
              home-manager.sharedModules = attrValues outputs.homeManagerModules;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ]
        );
    };

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
}
