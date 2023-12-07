{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.custom.editors;
in {
  options.custom.editors = {
    idea = mkEnableOption "Enable Intellij IDEA";
  };

  config = mkIf cfg.idea {
    home.packages = with pkgs.jetbrains; [
      jdk
      idea-community
    ];
  };
}
