{
  config,
  lib,
  ...
}:
let
  inherit (lib) types mkOption mkIf;
  cfg = config.custom.login;
in
{
  options.custom.login = {
    manager = mkOption {
      type = types.enum [
        "none"
        "gdm"
      ];
      default = "gdm";
    };
  };
  config = mkIf (cfg.manager != "none") {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm = {
      enable = cfg.manager == "gdm";
      wayland = true;
    };
  };
}
