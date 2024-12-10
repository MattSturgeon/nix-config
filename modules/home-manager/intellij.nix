{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  idea-plugins = [
    "ideavim"
  ];

  cfg = config.custom.editors;
in
{
  options.custom.editors = {
    idea = mkEnableOption "Enable Intellij IDEA";
  };

  config = mkIf cfg.idea {
    home.packages = with pkgs.jetbrains; [
      (plugins.addPlugins idea-community-bin idea-plugins)
    ];

    home.sessionVariables = {
      # Needed to launch Minecraft in Intellij
      LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
        libglvnd
        pulseaudio
      ]);
    };
  };
}
