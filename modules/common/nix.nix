{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  # nixos uses "dates", home-manager uses "frequency"
  frequency = if config.nix.gc ? "dates" then "dates" else "frequency";
  flake = import ../../flake.nix;
in
{
  config = {
    nixpkgs.config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };

    nix = {
      # This is default in NixOS, but must be set for home-manager
      package = pkgs.nix;

      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;
      # Add flake registries to legacy channels, making legacy nix commands consistent
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";

        # Deduplicate and optimize nix store
        auto-optimise-store = true;

        # Increase download buffer to 256MiB (default 64MiB)
        download-buffer-size = 256 * 1024 * 1024;

        # Inherit substituters and keys from the flake config
        # FIXME: NixOS defines `mkAfter [ "https://cache.nixos.org/" ]` by default,
        # however Home Manager does not.
        substituters = flake.nixConfig.extra-substituters;
        trusted-public-keys = flake.nixConfig.extra-trusted-public-keys;
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
