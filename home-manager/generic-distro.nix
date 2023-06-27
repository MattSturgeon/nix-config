{ config, pkgs, ... }: {

    # Enable settings that make nix/hm work better on _other_ distros
    targets.genericLinux.enable = true;

}
