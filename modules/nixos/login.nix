{
  config,
  options,
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
        "cosmic"
      ];
      default = if config.custom.desktop.cosmic then "cosmic" else "gdm";
      defaultText = lib.literalMD ''
        `"cosmic"` if `${options.custom.desktop.cosmic}` is enabled,
        otherwise `"gdm"`
      '';
    };
  };
  config = mkIf (cfg.manager != "none") {
    services.displayManager = {
      gdm = {
        enable = cfg.manager == "gdm";
        wayland = true;
      };
      cosmic-greeter.enable = cfg.manager == "cosmic";
    };
  };
}
