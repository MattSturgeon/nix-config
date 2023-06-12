
{ config, pkgs, ... }: {
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnome.gnome-tweaks
  ];

  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];

  environment.gnome.excludePackages = (with pkgs.gnome; [
    cheese
    gnome-terminal
    geary
    tali
    iagno
    atomix
  ]);
}
