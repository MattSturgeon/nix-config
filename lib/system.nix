{ util
, lib
, inputs
, self
, ...
}:
let
  inherit (builtins) length;
  inherit (lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (util.user) mkNixOSUserModule mkHMUserModule mkNixOSHMModule getHomeConfig;

  # Platform to use when system is not provided
  defaultSystem = "x86_64-linux";

  # Include all inputs in specialArgs;
  # now we don't have to overlay stuff into nixpkgs
  specialArgs = inputs // {
    inherit inputs self util;
  };

  # Build a NixOS config, including Home Manager configs for any hmUsers specified
  mkNixOSConfig =
    { hostname
    , system ? defaultSystem
    , users ? [ ]
    , hmUsers ? [ ]
    , nixosModules ? [ ]
    , homeManagerModules ? [ ]
    }: nixosSystem {
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
        ++ nixosModules
        ++ (
          if (length hmUsers) == 0 then [ ]
          else [
            inputs.home-manager.nixosModules.home-manager
            (mkNixOSHMModule ../hosts/${hostname} hmUsers)
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = homeManagerModules;
            }
          ]
        );
    };

  # Builds a standalone Home Manager config, independent of NixOS
  mkHMConfig =
    { hostname
    , user
    , system ? defaultSystem
    , modules ? [ ]
    }: homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs;
      modules = modules ++ [
        (mkHMUserModule user)
        (getHomeConfig ../hosts/${hostname} user.name)
      ];
    };
in
{
  # Global aliases
  inherit mkNixOSConfig mkHMConfig;

  system = { inherit mkNixOSConfig mkHMConfig defaultSystem; };
}
