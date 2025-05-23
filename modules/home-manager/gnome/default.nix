{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (builtins) map;
  inherit (lib) mkOption mkDefault;

  cfg = config.custom.gnome;
in
{
  imports = [ ./keybinds.nix ];

  options.custom.gnome = {
    extensions = mkOption {
      type = with lib.types; listOf package;
      description = "Gnome extension packages to install";
      default = with pkgs.gnomeExtensions; [
        appindicator
        dash-to-dock
        overview-background
        clipboard-indicator
        pip-on-top
      ];
    };

    favorites = mkOption {
      type = with lib.types; listOf str;
      description = "Favorite apps. A list of .desktop files";
      default = [ ];
    };
  };

  config = {
    custom.gnome = {
      keybinds.media.calculator = mkDefault "<Super>equal";

      favorites = [
        "org.gnome.Nautilus.desktop"
      ];
    };

    home.packages = cfg.extensions;

    dconf = {
      enable = true;
      # Useful commands:
      # dconf dump /
      # dconf watch /
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          dissabled-extensions = [ ];
          enabled-extensions = map (pkg: pkg.extensionUuid) cfg.extensions;
          favorite-apps = cfg.favorites;
        };
        "org/gnome/mutter" = {
          edge-tiling = true;
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
          show-battery-percentage = true;
        };
        "org/gnome/desktop/peripherals/mouse" = {
          accel-profile = "default";
          natural-scroll = false;
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          send-events = "enabled";
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
          edge-scrolling-enabled = false;
          natural-scroll = false;
        };
      };
    };
  };
}
