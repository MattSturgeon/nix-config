# My nix configuration

This is a nix flake defining my system and user configurations. It is currently work in progress and very incomplete.

## Initial bootstrap

If the experimental feature `nix-command` and `flakes` not enabled, run `nix-shell` from this directory to enable them.

Run `nixos-rebuild switch --flake .#matebook` to install the NixOS system.

If the host is not running NixOS (or isn't configured by this flake) use `home-manager` instead of `nixos-rebuild`
to build the standalone config: E.g. `home-manager switch --flake .#matt@desktop`.

## Updating

TODO
