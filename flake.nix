{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/nur";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Inherit some functions from ./lib
    inherit (outputs.lib) mkNixOSConfig mkHMConfig;
    inherit (outputs.lib.util) forAllSystems importChildren;

    # Define module lists, used in mkNixOSConfig & mkHMConfig
    nixosModules = importChildren ./modules/nixos;
    homeManagerModules = importChildren ./modules/home-manager;

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

    # NixOS configurations
    nixosConfigurations = {
      matebook = mkNixOSConfig {
        inherit nixosModules homeManagerModules;
        hostname = "matebook";
        hmUsers = [userMatt];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "matt@desktop" = mkHMConfig {
        modules = homeManagerModules;
        hostname = "desktop";
        user = userMatt;
      };
    };
  };
}
