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
      # PR https://github.com/NixOS/nixpkgs/pull/369259
      inputs.umu-launcher.legacyPackages.${system}.umu-launcher
      nexusmods-app-unfree
      mangohud
      goverlay # mangohud config GUI
    ];
  };
}
