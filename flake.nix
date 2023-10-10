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
    defaultSystem = "x86_64-linux";
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

    # Function to include a user's home-manager config in a NixOS system
    mkUser = {
      host,
      user,
      home ? "/home/${user}",
    }: {
      home-manager.users.${user} = import ./hosts/${host}/${user}.nix;
      home-manager.users.${user}.home = {
        username = user;
        homeDirectory = home;
      };
    };

    # Function to create a standard NixOS system
    # for a given hostname & platform
    mkSystem = name: {
      system ? defaultSystem,
      users ? [],
    }:
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
          ]
          ++ (
            # If users are defined, include their home-manager config
            if users == []
            then []
            else [
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
              (builtins.map
                (user:
                  mkUser {
                    inherit user;
                    host = name;
                  })
                users)
            ]
          );
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
      matebook = {
        users = ["matt"];
      };
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
