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
      inherit (outputs.lib.system) mkSystemConfig mkHomeConfig;
      inherit (outputs.lib.util) forAllSystems importChildren;

      # Define module lists, used in mkNixOSConfig & mkHMConfig
      commonModules = importChildren ./modules/common;
      nixosModules = commonModules ++ (importChildren ./modules/nixos);
      homeManagerModules = importChildren ./modules/home-manager;
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
      # TODO could mapAttrs these...
      nixosConfigurations = {
        matebook = mkSystemConfig {
          inherit nixosModules homeManagerModules;
          hostname = "matebook";
        };
      };

      # Standalone home-manager configuration entrypoint
      # TODO could mapAttrs these...
      homeConfigurations = {
        "matt@desktop" = mkHomeConfig {
          modules = commonModules ++ homeManagerModules;
          username = "matt";
          hostname = "desktop";
        };
      };
    };
}
