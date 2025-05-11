{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.boot;
in
{
  options.custom.boot = {
    splash = mkEnableOption "Boot splash";
  };

  config = mkIf cfg.splash {
    boot = {
      plymouth = {
        enable = true;
        theme = "breeze";
      };
      kernelParams = [ "quiet" ];
      initrd.systemd.enable = true;
    };
  };
}
