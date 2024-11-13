{ config, lib, pkgs, ... }:
let
  cfg = config.custom.gaming;
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
    ];

    nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
    ];
  };
}
