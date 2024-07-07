{ pkgs, lib, config, ... }:
let
  cfg = config.custom.element;
in
{
  options.custom.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Element matrix client.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.element-desktop ];
  };
}
