{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.custom.chat;
in
{
  options.custom.chat = {
    enable = lib.mkEnableOption "chat" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.signal-desktop
    ];
  };
}
