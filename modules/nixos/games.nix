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
in
{
  options.custom.gaming.enable = lib.mkEnableOption "gaming";

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    environment.systemPackages = with pkgs; [
      heroic # TODO: override extraLibraries ?
      prismlauncher
      steam-run
      (inputs.umu-launcher.packages.${system}.umu.override {
        version = inputs.umu-launcher.shortRev;
        truststore = true;
      })
      nexusmods-app-unfree
      mangohud
      goverlay # mangohud config GUI
    ];
  };
}
