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
          finalAttrs: prevAttrs: {
            # FIXME: Disable tests for now...
            # - Many tests are failing: https://github.com/Open-Wine-Components/umu-launcher/pull/574
            # - `versionCheckHook` is failing: https://github.com/Open-Wine-Components/umu-launcher/pull/575
            doInstallCheck =
              lib.throwIf (lib.hasInfix "-unstable-" finalAttrs.version)
                "Disabling umu versionCheckHook is not needed anymore"
                false;
          }
        );
      }))
      mcpelauncher-ui-qt
      nexusmods-app-unfree
      mangohud
      goverlay # mangohud config GUI
    ];
  };
}
