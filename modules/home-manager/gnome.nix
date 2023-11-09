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
  };

  config = {
    home.packages = cfg.extensions;
  };
}
