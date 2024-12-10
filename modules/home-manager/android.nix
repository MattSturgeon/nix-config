{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.custom.editors;
in
{
  options.custom.editors = {
    android = mkEnableOption "Enable Android Studio IDEA";
  };

  config = mkIf cfg.android {
    home.packages = [
      pkgs.android-studio
    ];
  };
}
