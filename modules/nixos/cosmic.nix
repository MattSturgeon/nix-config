{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  enabled = config.custom.desktop.cosmic;
in
{
  options.custom.desktop.cosmic = mkEnableOption "Cosmic desktop";

  config = mkIf enabled {
    services.desktopManager.cosmic = {
      enable = true;
    };
  };
}
