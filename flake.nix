{
  description = "My nix config";

  inputs = {
    systems.url = "path:./systems.nix";
    systems.flake = false;

    # PR adds support for relative path inputs, needed for the `systems` input
    # https://github.com/edolstra/flake-compat/pull/71
    flake-compat.url = "github:edolstra/flake-compat?ref=pull/71/merge";

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

    umu-launcher.url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
    umu-launcher.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./lib/flake-module.nix
        ./devshell/flake-module.nix
        ./nvim/flake-module.nix
        ./modules/flake-module.nix
        ./hosts/flake-module.nix
        ./isos/flake-module.nix
        ./treefmt/flake-module.nix
      ];

      # Allow inspecting flake-parts config in the repl
      # Adds the outputs debug.options, debug.config, etc
      debug = true;
    };
}
