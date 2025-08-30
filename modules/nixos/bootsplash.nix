{
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.custom.boot;

  # Backported from https://github.com/NixOS/nixpkgs/pull/438418
  nixosBreezePlymouth = pkgs.kdePackages.breeze-plymouth.override {
    logoFile = config.boot.plymouth.logo;
    logoName = "nixos";
    osName = "NixOS";
    osVersion = config.system.nixos.release;
  };
in
{
  options.custom.boot = {
    splash = mkEnableOption "Boot splash";
  };

  config = mkIf cfg.splash {
    boot = {
      plymouth = {
        enable = true;
        theme = "breeze";
        themePackages =
          lib.throwIf (options.boot.plymouth.themePackages.default != [ ])
            "${toString ./bootsplash.nix}: `${options.boot.plymouth.themePackaegs}` has been fixed, the manual backport can be removed"
            [ nixosBreezePlymouth ];
      };
      kernelParams = [ "quiet" ];
      initrd.systemd.enable = true;
    };
  };
}
