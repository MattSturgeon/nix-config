{ inputs
, ...
}: {
  custom = {
    boot.splash = true;
    desktop.gnome = true;
    impermanence.enable = true;
    impermanence.wipeOnBoot = true;
    flatpak.enable = true;
  };

  imports = with inputs.hardware.nixosModules; [
    # Hardware
    common-cpu-amd
    common-cpu-amd-pstate
    common-cpu-amd-zenpower
    common-gpu-amd
    common-pc-ssd
    common-hidpi
    ./hardware-configuration.nix
    ./disks.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
