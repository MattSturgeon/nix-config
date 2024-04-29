{ config, lib, pkgs, ... }: {
  options.custom.gaming = lib.mkEnableOption "Gaming";

  config = lib.mkIf config.custom.gaming {
    home.packages = with pkgs; [
      heroic
    ];
  };
}
