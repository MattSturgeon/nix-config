{
  description = "My nix config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    nixvim.url = "github:nix-community/nixvim";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    tmux-which-key.url = "github:alexwforsythe/tmux-which-key";
    tmux-which-key.flake = false;
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      imports = [
        ./lib/flake-module.nix
        ./nvim/flake-module.nix
        ./modules/flake-module.nix
        ./hosts/flake-module.nix
        ./isos/flake-module.nix
      ];

      perSystem = { config, self', inputs', pkgs, ... }: {
        # Define a bootstrapping shell, used by `nix develop`
        devShells = import ./shell.nix { inherit pkgs; };

        # Use the beta nixpkgs-fmt
        # Alejandra is too strict...
        formatter = pkgs.nixpkgs-fmt;
      };

      # Allow inspecting flake-parts config in the repl
      # Adds the outputs debug.options, debug.config, etc
      debug = true;
    };
}
