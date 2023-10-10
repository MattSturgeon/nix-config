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

    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Custom overlays
    overlays = import ./overlays {inherit inputs;};
    # Custom packages
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Custom modules
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # Modules to include in all nixos systems
    defaultModules = [
      ({...}: {nixpkgs.overlays = builtins.attrValues overlays;})
      nixosModules
      homeManagerModules
      # TODO
    ];

    # Function to create a standard pkgs set
    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = builtins.attrValues overlays;
        config.allowUnfree = true;
      };

    # Function to create a standard NixOS system
    # for a given hostname & platform
    mkSystem = name: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs outputs;};
        pkgs = mkPkgs system;
        modules =
          defaultModules
          ++ [
            ./hosts/${name}/hardware-configuration.nix
            ./hosts/${name}/configuration.nix
            ({...}: {networking.hostName = name;})
          ];
      };
  in {
    inherit packages overlays;

    # Make nix fmt use alejandra
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    devShells = forAllSystems (
      system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        }
    );

    # NixOS configurations
    nixosConfigurations = builtins.mapAttrs mkSystem {
      matebook = "x86_64-linux";
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "matt@desktop" = home-manager.lib.homeManagerConfiguration {
        # Home-manager requires 'pkgs' instance
        pkgs = mkPkgs "x86_64-linux";
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/desktop/home.nix
        ];
      };
    };
  };
}
