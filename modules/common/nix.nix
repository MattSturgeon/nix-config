{ inputs
, config
, lib
, pkgs
, ...
}:
let
  # nixos uses "dates", home-manager uses "frequency"
  frequency = if config.nix.gc ? "dates" then "dates" else "frequency";
in
{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
    };

    nix = {
      # This is default in NixOS, but must be set for home-manager
      package = pkgs.nix;

      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      settings = {
        # Set nix-path in nix.settings because nix.nixPath isn't supported on home-manager
        # Add flake registries to legacy channels, making legacy nix commands consistent
        nix-path = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";

        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        # Increase download buffer to 256MiB (default 64MiB)
        download-buffer-size = 256 * 1024 * 1024;
      };

      # Enable garbage collection
      gc = {
        automatic = true;
        ${frequency} = "weekly";
        options = "--delete-older-than 30d";
      };
    };
  };
}
