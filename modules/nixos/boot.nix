{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption;
  cfg = config.custom.boot;
in {
  options.custom.boot = {
    manager = mkOption {
      description = "The boot manager to use";
      default = "systemd-boot";
      type = with lib.types; enum ["systemd-boot"];
    };
  };

  config = {
    boot.loader.systemd-boot.enable = cfg.manager == "systemd-boot";
  };
}
