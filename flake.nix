{
  description = "My nix config";

  inputs = {
    systems.url = ./systems.nix;
    systems.flake = false;

    flake-compat.url = "github:NixOS/flake-compat";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.systems.follows = "systems";
      inputs.flake-parts.follows = "flake-parts";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tmux-which-key = {
      url = "github:alexwforsythe/tmux-which-key";
      flake = false;
    };

    umu-launcher = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    commit-lock-file-summary = "chore(flake): update inputs";
    extra-substituters = [
      "https://matt-sturgeon.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "matt-sturgeon.cachix.org-1:wyWywp8URe+OYn3t+xDXoZkmsYzFZ+WpDC6rsAQ+MX4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    allow-import-from-derivation = false;
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

      # Output a build matrix for CI
      flake.githubActions = inputs.nix-github-actions.lib.mkGithubMatrix {
        inherit (inputs.self) checks;
      };

      # Allow inspecting flake-parts config in the repl
      # Adds the outputs debug.options, debug.config, etc
      debug = true;
    };
}
