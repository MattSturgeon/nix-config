{ inputs, ... }:
let
  hardware = {
    # This is a Huawei MACH-WX9, but MACHC-WA is almost identical
    inherit (inputs.hardware.nixosModules)
      huawei-machc-wa
      common-hidpi
      ;
    # huawei-machc-wa assumes newer comet-lake CPUs,
    # also import config for our older kaby-lake CPU
    kaby-lake = inputs.hardware + "/common/cpu/intel/kaby-lake";
  };
in
{
  custom = {
    boot.splash = true;
    desktop.gnome = true;
    impermanence.enable = true;
    impermanence.wipeOnBoot = true;
    battery.optimise = true;
    flatpak.enable = true;
    gaming.enable = true;
  };

  imports = builtins.attrValues hardware ++ [
    ./hardware-configuration.nix
    ./disks.nix
  ];

  boot.initrd.availableKernelModules = [
    "usb_storage"
    "sd_mod"
  ];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
