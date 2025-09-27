{ lib, config, ... }:
let
  inherit (lib) types mkIf mkOption;
  cfg = config.custom.sync;
in
{
  options.custom.sync = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Syncthing syncing";
    };
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      extraOptions = [ "--no-default-folder" ];
    };
  };
}
