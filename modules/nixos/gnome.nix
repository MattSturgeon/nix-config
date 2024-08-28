{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  enabled = config.custom.desktop.gnome;
in
{
  options.custom.desktop.gnome = mkEnableOption "Gnome desktop";

  config = mkIf enabled {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    # Enable dconf so it can be configured by home-manager
    programs.dconf.enable = true;

    xdg.portal.enable = true;

    services.udev.packages = with pkgs.gnome; [
      gnome-settings-daemon
    ];

    environment.systemPackages = with pkgs; [
      file-roller
      nautilus-open-any-terminal
    ];

    # Exclude some default gnome packages
    environment.gnome.excludePackages = with pkgs; [
      baobab
      cheese
      eog
      epiphany
      gnome-connections
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-weather
      simple-scan
      yelp
    ];
  };
}
