{ config
, lib
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  enabled = config.custom.desktop.hyprland;
in
{
  options.custom.desktop.hyprland = mkEnableOption "Hyprland desktop";

  config = mkIf enabled {
    services.xserver.enable = true;
    programs.hyprland.enable = true;
    # TODO Implement a working config
  };
}
