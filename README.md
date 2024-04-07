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

## Adding a new system

To add a new system, first create a new directory in `hosts` named the system hostname.

In this directory should be a NixOS module file named `configuration.nix` and a home-manager module file named `home.nix`.
The NixOS module can be ommitted it the configuration is a standalone home-manager config, not targeting NixOS.
The `home.nix` file can also be named `<user>.nix` (replacing `<user>` with a username) if the system has multiple home-manager configs.

A "user" config should be declared in `flake.nix`. Since I only have one user, I currently just declare `userMatt` in the outputs' let block:

```nix
# Define my user, used by most configurations
# see initUser in lib/user.nix
someUser = {
  name = "username";
  description = "Full Name";
  initialPassword = "init";
  isAdmin = true;
};
```

Finally, the configuration should be declared in `flake.nix`'s outputs, e.g:

```nix
# NixOS configurations
nixosConfigurations = {
  hostnameHere = mkNixOSConfig {
    inherit nixosModules homeManagerModules;
    hostname = "matebook";
    hmUsers = [someUser];
  };
};
```

```nix
# Standalone home-manager configuration
homeConfigurations = {
  "username@hostname" = mkHMConfig {
    modules = homeManagerModules;
    hostname = "hostname-here";
    user = someUser;
  };
};
```

## TODO

- [ ] Add a way to specify NixOS user config in my "user" config. This would enable setting login shell.

