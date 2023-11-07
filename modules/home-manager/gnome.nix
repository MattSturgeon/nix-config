{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) listToAttrs map elemAt length;
  inherit (lib) types mkOption;

  # Helper function that converts a list of names into a list list
  # of basic string options.
  strOptions = list: (listToAttrs (map (elm: {
      name = elm;
      value = {
        name = elm;
        type = types.str;
        default = "";
      };
    })
    list));

  mapListToAttrsWithI = f: list: let
    # Based on binaryMerge in mergeAttrsList
    # Divide and conquere; call f on each index and combine the result
    binaryMap = start: end:
      if end - start > 1
      then
        binaryMap start (start + (end - start) / 2)
        // binaryMap (start + (end - start) / 2) end
      else f start (elemAt list start);
  in
    if list == []
    then {}
    else binaryMap 0 (length list);

  # map cfg.binds into actual dconf settings
  binds =
    mapListToAttrsWithI (i: elm: {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${i}" = elm;
    })
    cfg.binds;

  cfg = config.custom.gnome;
in {
  options.custom.gnome = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
    extensions = mkOption {
      type = types.listOf types.package;
      default = with pkgs.gnomeExtensions; [
        appindicator
        dash-to-dock
      ];
    };
    favorites = mkOption {
      type = types.listOf types.str;
      default = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "kitty.desktop"
      ];
    };
    binds = mkOption {
      type = with types;
        listOf (submodule {
          options = strOptions ["name" "bind" "command"];
        });
      description = ''
        A list of custom keybinds.
      '';
      default = [];
    };
    wmBinds = mkOption {
      type = with types;
        submodule {
          options = strOptions [
            "activate-window-menu"
            "toggle-message-tray"
            "close"
            "minimize"
            "maximize"
            "toggle-maximized"
            "unmaximize"
            "move-to-monitor-down"
            "move-to-monitor-left"
            "move-to-monitor-right"
            "move-to-monitor-up"
            "move-to-workspace-down"
            "move-to-workspace-up"
          ];
        };
      description = ''
        Key=>binding
      '';
      default = {};
    };
    mediaBinds = mkOption {
      description = "Key=>binding for media keys";
      type = types.submodule {
        options = strOptions ["next" "previous" "play"];
      };
      default = {};
    };
  };

  config = {
    home.packages = cfg.extensions;

    dconf.enable = true;
    dconf.settings =
      {
        "org/gnome/shell" = {
          disabled-user-extensions = false;
          dissabled-extensions = "disabled";
          enabled-extensions = map (pkg: pkg.extensionUuid) cfg.extensions;
          favorite-apps = cfg.favorites;
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = false;
        };
        "org/gnome/deskotp/wm/keybinds" = cfg.wmBinds;
        "org/gnome/settings-daemon/plugins/media-keys" =
          cfg.mediaBinds
          // {custom-keybinds = lib.mapAttrsToList (name: value: "/${name}/") binds;};
      }
      // binds;
  };
}
