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

    # Define my user, used by most configurations
    # see initUser in lib/user.nix
    userMatt = {
      name = "matt";
      description = "Matt Sturgeon";
      initialPassword = "init";
      isAdmin = true;
    };

    /*
    Generates an attribute set by mapping a function over each system listed.

    Example:
      forAllSystems (system: "Uses " + system)
      => { x86_64-linux = "Uses x86_64-linux"; aarch64-darwin = "Uses aarch64-darwin"; ... }

    Type:
      forAllSystems :: (String -> Any) -> AttrSet
    */
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    # Custom functions
    util = import ./lib {inherit inputs outputs;};
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
    lib = util;

    # Custom modules
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;

    # NixOS configurations
    nixosConfigurations = {
      matebook = util.mkNixOSConfig {
        hostname = "matebook";
        hmUsers = [userMatt];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "matt@desktop" = util.mkHMConfig {
        hostname = "desktop";
        user = userMatt;
      };
    };
  };
}
