{ util
, lib
, inputs
, outputs
, ...
}:
with builtins; let
  inherit (lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (util.util) nixChildren;

  # Platform to use when system is not provided
  defaultSystem = "x86_64-linux";

  # Include all inputs in specialArgs;
  # now we don't have to overlay stuff into nixpkgs
  specialArgs = inputs // { inherit inputs outputs util; };

  # Build a NixOS config, including Home Manager configs for any hmUsers specified
  mkSystemConfig =
    { hostname
    , system ? defaultSystem
    , nixosModules ? [ ]
    , homeManagerModules ? [ ]
    , ...
    }: nixosSystem {
      inherit system specialArgs;
      modules = nixosModules ++ [
        {
          # Configure hostname
          networking.hostName = hostname;

          # Pass modules to Home Manager
          home-manager.sharedModules = homeManagerModules;
        }
        inputs.home-manager.nixosModules.home-manager
        (getSystemConfig hostname)
      ];
    };

  # Builds a standalone Home Manager config, independent of NixOS
  mkHomeConfig =
    { hostname
    , username
    , home ? "/home/${username}"
    , system ? defaultSystem
    , modules ? [ ]
    , ...
    }: homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs;
      modules = modules ++ [
        {
          # Pass in environment info
          custom.env.host = hostname;
          home.username = username;
          home.homeDirectory = home;
        }
        (getHomeConfig hostname username)
      ];
    };

  getSystemConfig = username: ../system/${username}/default.nix;

  getHomeConfig = hostname: username: ../home + "/${username}@${hostname}/default.nix";
in
{
  system = { inherit mkSystemConfig mkHomeConfig getSystemConfig getHomeConfig defaultSystem; };
}
