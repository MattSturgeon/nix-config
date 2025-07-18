{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.custom.sound;
in
{
  options.custom.sound = {
    jack = mkEnableOption "Enable Jack";
  };

  config = {
    # The nixos wiki recomends using rtkit with pipewire
    security.rtkit.enable = true;

    # pipewire and pulseaudio conflict
    services.pulseaudio.enable = mkForce false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.jack;
      wireplumber.extraConfig = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
          ];
        };
      };
    };
  };
}
