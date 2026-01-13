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

    environment.persistence."/persist".files = [
      # The OpenRGB system service stores its server-side configuration here.
      # NOTE: the GUI/client still reads and writes per-user config,
      # which does not affect the server.
      "/var/lib/OpenRGB/OpenRGB.json"
    ];
  };
}
