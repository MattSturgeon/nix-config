# Modules

This directory contains the meat of my config.

## Default modules

Almost all config and options are defined in the `nixos` and `home` directories, output as `nixosModules.default` and `homeModules.default` respectively.

All options and configuration in the default modules are disabled by default.

## Non-NixOS module

A special home-manager module exists to enable better nix compatibility on non-NixOS systems. E.g. setting up nixGL or configuring a standalone nix install.

This module is located in `nonNixOSHome` and is output as `homeModules.nonNixOS`.

