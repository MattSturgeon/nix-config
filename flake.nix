{
  description = "My nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim.url = "github:pta2002/nixvim";

    nixgl.url = "github:guibou/nixGL";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    nixgl,
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
      # Make `nix fmt` use alejandra
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      # Devshell for bootstrapping
      # Acessible through `nix develop` or `nix-shell` (legacy)
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; }
      );

      # Package overlays
      overlays = {
        nixgl = nixgl.overlays.default;
      };

      legacyPackages = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
      );

      # NixOS configuration entrypoint
      # Available through `nixos-rebuild --flake .#matts-laptop`
      nixosConfigurations = {
        "matts-laptop" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
	    ./nixos/settings.nix

	    ./nixos/bootsplash.nix
	    ./nixos/sleep.nix
	    ./nixos/udisks.nix
	    ./nixos/shell.nix
	    ./nixos/input.nix
	    ./nixos/sound.nix
	    ./nixos/gdm.nix
	    ./nixos/gnome.nix
	    ./nixos/printing.nix
	    ./nixos/docker.nix

            # Main nixos configuration file
            ./nixos/configuration.nix
	    ./hardware-config/matts-laptop.nix
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through `home-manager --flake .#matt`
      homeConfigurations = {
        "matt@matts-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
	    ./home-manager/system.nix
	    ./home-manager/java.nix
	    ./home-manager/shell.nix
	    ./home-manager/starship.nix
	    ./home-manager/zellij.nix
	    ./home-manager/gpg.nix
	    ./home-manager/git.nix
	    ./home-manager/fonts.nix
	    ./home-manager/kitty.nix
	    ./home-manager/neovim.nix
	    ./home-manager/vscode.nix
	    ./home-manager/firefox.nix

            # Main home-manager configuration file
            ./home-manager/home.nix

	    # Use nixvim modules in this configuration
	    nixvim.homeManagerModules.nixvim
          ];
        };
        "matt@matts-desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
	    ./home-manager/generic-distro.nix
	    ./home-manager/system.nix
	    ./home-manager/shell.nix
	    ./home-manager/starship.nix
	    ./home-manager/zellij.nix
	    ./home-manager/gpg.nix
	    ./home-manager/git.nix
	    ./home-manager/fonts.nix
	    ./home-manager/kitty.nix
	    ./home-manager/neovim.nix
	    ./home-manager/vscode.nix
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
