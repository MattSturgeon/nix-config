# My nix configuration

This is a nix flake defining my system and user configurations.
It is a constant work-in-progress and not intended as a template, although you may find some bits interesting.

## Initial bootstrap

If the experimental feature `nix-command` and `flakes` not enabled, run `nix-shell` from this directory to enable them.

## Installing

Run `nixos-rebuild switch --flake .#config` to install the NixOS system, replacing `config` with the name of the configuration.
The `.#config` part is optional if your system hostname matches the name of the configuration.

If the host is not running NixOS (or is configured seperately from home-manager) use `home-manager` instead of `nixos-rebuild`
to build the standalone config: E.g. `home-manager switch --flake .#matt@desktop`.

## Fresh install

To install for the first time, from a live USB, first run `disko` to create the partition layout, then run `nixos-install`.

```shell
sudo disko --flake github:MattSturgeon/nix-config#matebook --mode disko
sudo nixos-install --flake github:MattSturgeon/nix-config#matebook --no-root-password
```

`disko` will wipe the disk specified in `matebook`'s disko config, create the partitions, and mount them at `/mnt`.

`nixos-install` will install the `matebook` nixos configuration into `/mnt`.


## Live USB

A custom bootable ISO can be generated using `nix build .#installer` and then flashed using `dd`, `gnome-disks` or similar.

The bootable ISO contains much of my normal configuration for convenience. As time goes on I plan to ensure that useful tools
and scripts are also included.

## Updating

Update the flake loak file by using `nix flake update`, optionally with `--commit-lock-file`.

Once the lock file is updated you'll still need to install using `nixos-rebuild` or `home-manager`.
See the [installing](#installing) section above.

On a non-NixOS system, the nix package manager will also need to be managed seperately.
It can be updated using `nix upgrade-nix`.

