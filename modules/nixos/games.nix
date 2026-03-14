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
      (inputs.umu-launcher.packages.${system}.default.override (prev: {
        umu-launcher-unwrapped = prev.umu-launcher-unwrapped.overrideAttrs (
          finalAttrs: prevAttrs:
          # Disable versionCheckHook instead of installCheckPhase
          # Backports https://github.com/Open-Wine-Components/umu-launcher/pull/632
          lib.throwIf (prevAttrs.doInstallCheck or true || prevAttrs.dontVersionCheck or false)
            "umu-launcher#632 has landed"
            {
              doInstallCheck = true;
              dontVersionCheck = true;
            }
        );
      }))
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
