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
      # FIXME: we install protontricks manually below
      protontricks.enable = false;
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
      packwiz # Manage MC modpacks

      # FIXME: 2026-10-09: Workaround build failure due to using steam-run in a test
      # Manually define `programs.steam.protontricks` to disable bwrap test
      (
        (protontricks.override {
          # Re-implement https://github.com/NixOS/nixpkgs/blob/bdfebd6f/nixos/modules/programs/steam.nix#L12
          extraCompatPaths =
            lib.makeSearchPathOutput "steamcompattool" ""
              config.programs.steam.extraCompatPackages;
        }).overrideAttrs
          (
            finalAttrs: prevAttrs: {
              disabledTests =
                lib.throwIf (prevAttrs ? disabledTests)
                  "protontricks has been updated to disable tests, workaround can be removed"
                  [
                    # This test executes ldconfig via steam-run, which relies on bwrap.
                    # bwrap requires unprivileged user namespaces, causing the test to fail
                    # on hardened kernels or restrictive distros (like Ubuntu 24.04).
                    "test_get_runtime_library_paths"
                  ];
            }
          )
      )
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
