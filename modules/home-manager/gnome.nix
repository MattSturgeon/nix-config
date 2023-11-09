{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkOption;

  cfg = config.custom.gnome;
in {
  options.custom.gnome = {
    extensions = mkOption {
      type = with lib.types; listOf package;
      description = "Gnome extension packages to install";
      default = with pkgs.gnomeExtensions; [
        appindicator
        dash-to-dock
      ];
    };

    favorites = mkOption {
      type = with lib.types; listOf str;
      description = "Favorite apps. A list of .desktop files";
      default = [
        "firefox.desktop"
        "kitty.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
  };

  config = {
    home.packages = cfg.extensions;

    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          dissabled-extensions = [];
          enabled-extensions = map (pkg: pkg.extensionUuid) cfg.extensions;
	  favorite-apps = cfg.favorites;
        };
      };
    };
  };
}
