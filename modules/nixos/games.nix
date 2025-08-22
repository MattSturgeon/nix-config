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

  minecraftPorts = {
    bedrock = 19132;
    java = 25565;
    lanJava = {
      from = 40000;
      to = 65535;
    };
  };
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
      inputs.umu-launcher.packages.${system}.default
      nexusmods-app-unfree
      mangohud
      goverlay # mangohud config GUI
    ];

    networking.firewall = {
      allowedTCPPorts = [
        minecraftPorts.bedrock
        minecraftPorts.java
      ];
      allowedUDPPorts = [
        minecraftPorts.bedrock
        minecraftPorts.java
      ];
      allowedTCPPortRanges = [
        minecraftPorts.lanJava
      ];
      allowedUDPPortRanges = [
        minecraftPorts.lanJava
      ];
    };
  };
}
