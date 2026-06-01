{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.custom.gaming;
  inherit (pkgs.stdenv.hostPlatform) system;

  steam = pkgs.steam.override {
    inherit extraEnv;
  };

  heroic = pkgs.heroic.override {
    inherit extraEnv;
  };

  extraEnv = {
    PROTON_ENABLE_WAYLAND = true;
  };
in
{
  options.custom.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = steam;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    environment.systemPackages = with pkgs; [
      heroic
      prismlauncher
      steam-run
      inputs.umu-launcher.packages.${system}.default
      mcpelauncher-ui-qt
      nexusmods-app-unfree
      mangohud
      goverlay # mangohud config GUI
    ];

    nixpkgs.config = {
      allowInsecurePredicate =
        pkg:
        lib.elem (lib.getName pkg) [
          # NexusMods.App has been abandoned
          # TODO: Drop from Nixpkgs & my config
          "nexusmods-app-unfree"
        ];
    };
  };
}
