{ config, lib, ... }:
let
  cfg = config.custom.rgb;
in
{
  options.custom.rgb = {
    enable = lib.mkEnableOption "openrgb";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb.enable = true;
  };
}
