{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:pta2002/nixvim";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    ...
  }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    rec {
      # Devshell for bootstrapping
      # Acessible through `nix develop` or `nix-shell` (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # TODO Add any overlays/modules here?

      # NixOS configuration entrypoint
      # Available through `nixos-rebuild --flake .#matts-laptop`
      nixosConfigurations = {
        "matts-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
	    ./nixos/bootsplash.nix
	    ./nixos/gdm.nix
	    ./nixos/gnome.nix

            # Main nixos configuration file
            ./nixos/configuration.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through `home-manager --flake .#matt`
      homeConfigurations = {
        "matt" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
	    ./home-manager/system.nix
	    ./home-manager/gpg.nix
	    ./home-manager/git.nix
	    ./home-manager/neovim.nix
	    ./home-manager/firefox.nix

            # Main home-manager configuration file
            ./home-manager/home.nix

	    # Use nixvim modules in this configuration
	    nixvim.homeManagerModules.nixvim
          ];
        };
      };
    };
}
