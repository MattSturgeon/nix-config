{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    tmux-which-key.url = "github:alexwforsythe/tmux-which-key";
    tmux-which-key.flake = false;
  };

  outputs =
    { self
    , nixpkgs
    , ...
    } @ inputs:
    let
      inherit (self) outputs;

      # Inherit some functions from ./lib
      inherit (outputs.lib) mkNixOSConfig mkHMConfig;
      inherit (outputs.lib.util) forAllSystems importChildren;

      # Define module lists, used in mkNixOSConfig & mkHMConfig
      commonModules = importChildren ./modules/common;
      nixosModules = commonModules ++ (importChildren ./modules/nixos);
      homeManagerModules = importChildren ./modules/home-manager;

      # Define my user, used by most configurations
      # see initUser in lib/user.nix
      userMatt = {
        name = "matt";
        description = "Matt Sturgeon";
        initialPassword = "init";
        isAdmin = true;
      };
    in
    {
      # Use the beta nixpkgs-fmt
      # Alejandra is too strict...
      formatter = forAllSystems (system: pkgs: pkgs.nixpkgs-fmt);

      # Define a bootstrapping shell, used by `nix develop`
      devShells = forAllSystems (system: pkgs: import ./shell.nix { inherit pkgs; });

      # Custom library functions
      lib = import ./lib { inherit inputs outputs; };

      # NixOS configurations
      nixosConfigurations = {
        matebook = mkNixOSConfig {
          inherit nixosModules homeManagerModules;
          hostname = "matebook";
          hmUsers = [ userMatt ];
        };
      };

      # Standalone home-manager configuration entrypoint
      homeConfigurations = {
        "matt@desktop" = mkHMConfig {
          modules = commonModules ++ homeManagerModules;
          hostname = "desktop";
          user = userMatt;
        };
      };
    };
}
