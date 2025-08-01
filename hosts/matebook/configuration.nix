{
  inputs,
  ...
}:
{
  custom = {
    boot.splash = true;
    desktop.gnome = true;
    impermanence.enable = true;
    impermanence.wipeOnBoot = true;
    battery.optimise = true;
    flatpak.enable = true;
  };

  imports = with inputs.hardware.nixosModules; [
    # Hardware
    # intelBusId = "PCI:0:2:0"; nvidiaBusId = "PCI:1:0:0";
    common-cpu-intel
    # NOTE: this module is deprecated, planned to be upstreamed to nixpkgs
    # See https://github.com/NixOS/nixos-hardware/issues/992
    "${inputs.hardware}/common/cpu/intel/kaby-lake"
    common-gpu-nvidia-disable # Disable MX150 for better battery
    common-pc-laptop-ssd
    common-hidpi
    ./hardware-configuration.nix
    ./disks.nix
  ];

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "sd_mod"
  ];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
