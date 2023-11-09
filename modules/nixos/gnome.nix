{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  enabled = config.custom.desktop.gnome;
in {
  options.custom.desktop.gnome = mkEnableOption "Gnome desktop";

  config = mkIf enabled {
    services.xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = [pkgs.xterm];
    };

    # Enable dconf so it can be configured by home-manager
    programs.dconf.enable = true;

    xdg.portal.enable = true;

    services.udev.packages = with pkgs.gnome; [
      gnome-settings-daemon
    ];

    environment.systemPackages =
      (with pkgs; [
        nautilus-open-any-terminal
      ])
      ++ (with pkgs.gnome; [
        file-roller
      ]);

    # Exclude some default gnome packages
    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-connections
        gnome-console
        gnome-photos
        # gnome-text-editor
      ])
      ++ (with pkgs.gnome; [
        baobab
        cheese
        eog
        epiphany
        # gnome-calculator
        # gnome-calendar
        # gnome-characters
        # gnome-clocks
        gnome-contacts
        # gnome-font-viewer
        # gnome-logs
        gnome-maps
        gnome-music
        # gnome-system-monitor
        gnome-terminal
        gnome-weather
        # nautilus
        simple-scan
        # totem
        yelp
      ]);
  };
}
