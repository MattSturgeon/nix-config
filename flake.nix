{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    hardware,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Inherit some functions from ./lib
    inherit (outputs.lib) forAllSystems mkNixOSConfig mkHMConfig;

    # Define my user, used by most configurations
    # see initUser in lib/user.nix
    userMatt = {
      name = "matt";
      description = "Matt Sturgeon";
      initialPassword = "init";
      isAdmin = true;
    };
  in {
    # Make nix fmt use alejandra
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Define a bootstrapping shell, used by `nix develop`
    devShells = forAllSystems (
      system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        }
    );

    # Custom library functions
    lib = import ./lib {inherit inputs outputs;};

    # Custom modules
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # NixOS configurations
    nixosConfigurations = {
      matebook = mkNixOSConfig {
        hostname = "matebook";
        hmUsers = [userMatt];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "matt@desktop" = mkHMConfig {
        hostname = "desktop";
        user = userMatt;
      };
    };
  };
}
