{
  inputs,
  pkgs,
  ...
}:
{
  custom = {
    boot.splash = true;
    desktop.gnome = true;
    docker.enable = true;
    impermanence.enable = true;
    impermanence.wipeOnBoot = true;
    flatpak.enable = true;
    gaming.enable = true;
    rgb.enable = true;
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
    ./sensors.nix
  ];

  # TODO: switch to `hardware.fancontrol` or `services.pid-fan-controller`,
  # or maybe come up with rfc42 config for coolercontrol?
  # See https://docs.coolercontrol.org/wiki/config-files.html
  programs.coolercontrol.enable = true;

  environment.systemPackages = with pkgs; [
    act # Allows running github actions locally
  ];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
