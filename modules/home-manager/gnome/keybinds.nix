{
  lib,
  config,
  ...
}:
let
  inherit (builtins) mapAttrs listToAttrs;
  inherit (lib) mkOption toList filterAttrs;

  schema = import ./bind-schema.nix;

  # Map a list of dconf keys into keybind options
  mkBindOptions =
    keys:
    listToAttrs (
      map (name: {
        inherit name;
        value = mkOption {
          type = with lib.types; nullOr str;
          default = null;
          description = "Set binding for ${name}";
        };
      }) keys
    );

  # Fn to convert keybinds into dconf settings
  processBinds =
    binds:
    mapAttrs (name: value: toList value) (
      filterAttrs (name: value: value != null && value != "") binds
    );

  cfg = config.custom.gnome.keybinds;
  enabled = config.custom.gnome.enable;
in
{
  options.custom.gnome.keybinds = {
    media = mkBindOptions schema.media;
    shell = mkBindOptions schema.shell;
    wm = mkBindOptions schema.wm;

    custom = mkOption {
      type =
        with lib.types;
        listOf (submodule {
          options = {
            name = mkOption {
              type = str;
              description = "The name of this keybind";
            };
            binding = mkOption {
              type = str;
              description = "The keys to be bound to";
            };
            command = mkOption {
              type = str;
              description = "The command to be run";
            };
          };
        });
      description = "A list of custom keybinds.";
      default = [
        {
          name = "Kitty";
          binding = "<Super>Return";
          command = "kitty";
        }
      ];
    };
  };

  config = lib.mkIf enabled {
    dconf = {
      enable = true;
      settings =
        let
          inherit (builtins) listToAttrs;
          inherit (lib) imap0 mapAttrsToList;

          # Convert custom keybinds into actual dconf settings
          customBinds = listToAttrs (
            imap0 (index: value: {
              name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString index}";
              inherit value;
            }) cfg.custom
          );

          # A list of dconf keys that contain custom binds
          customBindNames = mapAttrsToList (name: value: "/${name}/") customBinds;
        in
        customBinds
        // {
          # media-keys lists custom-keybindings too
          "org/gnome/settings-daemon/plugins/media-keys" =
            (processBinds cfg.media)
            // (if customBindNames == [ ] then { } else { custom-keybindings = customBindNames; });
          "org/gnome/shell/keybindings" = processBinds cfg.shell;
          "org/gnome/desktop/wm/keybindings" = processBinds cfg.wm;
        };
    };
  };
}
