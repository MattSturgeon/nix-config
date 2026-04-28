{
  lib,
  config,
  pkgs,
  specialArgs,
  ...
}:
let
  inherit (lib) mkOption mkDefault;

  cfg = config.custom.gnome;
in
{
  imports = [ ./keybinds.nix ];

  options.custom.gnome = {
    enable = mkOption {
      type = lib.types.bool;
      description = "Whether to configure GNOME";
      default = specialArgs.osConfig.custom.desktop.gnome or true;
      defaultText = lib.literalMD ''
        `osConfig.custom.desktop.gnome` if present,
        otherwise `true`
      '';
    };

    extensions = mkOption {
      type = with lib.types; listOf package;
      description = "Gnome extension packages to install";
      default = with pkgs.gnomeExtensions; [
        appindicator
        (dash-to-dock.overrideAttrs (old: {
          patches = old.patches or [ ] ++ [
            # https://github.com/micheleg/dash-to-dock/pull/2529
            (pkgs.fetchpatch {
              name = "fix-intellihide-not-hiding.patch";
              url = "https://github.com/micheleg/dash-to-dock/commit/0a60df0e2570738cc63d1df222f48f56fe72cccb.patch";
              hash = "sha256-Rc0oYCJY6Zn2nUiLUC/bfe6RQ6gYN1MRv6pWfEz3+Jk=";
            })
          ];
        }))
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

  config = lib.mkIf cfg.enable {
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
