{ lib
, hardware
, ...
}: {
  custom = {
    boot.splash = true;
    desktop.gnome = true;
  };

  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "vscode" "vscode-extension-github-codespaces" "vscode-extension-ms-vscode-cpptools" ];
  };

  imports = with hardware.nixosModules; [
    # Hardware
    # intelBusId = "PCI:0:2:0"; nvidiaBusId = "PCI:1:0:0";
    common-cpu-intel
    common-cpu-intel-kaby-lake
    common-gpu-nvidia-disable # Disable MX150 for better battery
    common-pc-laptop-ssd
    common-hidpi
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
