{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.rgb;
  inherit (pkgs.stdenv.hostPlatform) system;
  openrgbNeedsUpdating = lib.versionOlder pkgs.openrgb.version "1.0";
in
{
  options.custom.rgb = {
    enable = lib.mkEnableOption "openrgb";
  };

  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = lib.mkIf openrgbNeedsUpdating inputs.nixpkgs-openrgb-pr.legacyPackages.${system}.openrgb;
    };

    warnings = lib.mkIf (!openrgbNeedsUpdating) [
      "pkgs.openrgb is now ${pkgs.openrgb.version} and no longer needs overriding in modules/nixos/rgb.nix."
    ];
  };
}
