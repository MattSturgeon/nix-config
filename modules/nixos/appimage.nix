{ config, lib, ... }:
let
  cfg = config.custom.appimage;
in
{
  options.custom.appimage = {
    enable = lib.mkEnableOption "appimage" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
