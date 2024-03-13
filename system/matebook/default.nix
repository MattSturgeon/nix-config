{ hardware
, ...
}: {
  custom = {
    boot.splash = true;
    desktop.gnome = true;

    # Enable user "matt"
    users.matt.enable = true;
  };

  imports = with hardware.nixosModules; [
    # Hardware
    # intelBusId = "PCI:0:2:0"; nvidiaBusId = "PCI:1:0:0";
    common-cpu-intel
    common-cpu-intel-kaby-lake
    common-gpu-nvidia-disable # Disable MX150 for better battery
    common-pc-laptop-ssd
    common-hidpi
    ./hardware-configuration.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
