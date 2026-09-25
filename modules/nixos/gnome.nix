{
  config,
  lib,
  pkgs,
  ...
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
      excludePackages = [ pkgs.xterm ];
    };

    services.desktopManager.gnome.enable = true;

    # Enable dconf so it can be configured by home-manager
    programs.dconf.enable = true;

    xdg.portal.enable = true;

    services.udev.packages = [
      pkgs.gnome-settings-daemon
    ];

    environment.systemPackages = [
      pkgs.file-roller
    ];

    # Exclude some gnome packages
    # See core apps list in NixOS module:
    # https://github.com/NixOS/nixpkgs/blob/e554fab7/nixos/modules/services/desktop-managers/gnome.nix#L470
    environment.gnome.excludePackages = [
      pkgs.epiphany
      pkgs.gnome-text-editor
      pkgs.gnome-calendar
      pkgs.gnome-console
      pkgs.gnome-contacts
      pkgs.gnome-maps
      pkgs.gnome-music
      pkgs.yelp
    ];
  };
}
