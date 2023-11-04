{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (builtins) baseNameOf;
  inherit (lib) types getExe writeShellScriptBin mkIf mkEnableOption mkOption;

  cfg = config.custom.otherHost;
  nixGL = cfg.glWrapper;
  nixVulkan = cfg.vkWrapper;
in {
  options.custom.otherHost = {
    enable = mkEnableOption "Enable settings for non-nixOS hosts";

    glWrapper = mkOption {
      type = types.package;
      default = inputs.nixgl.nixGLIntel;
    };

    vkWrapper = mkOption {
      type = types.package;
      default = inputs.nixgl.nixVulkanIntel;
    };

    glPkgNames = mkOption {
      type = types.listOf types.str;
      default = ["kitty"];
    };

    vkPkgNames = mkOption {
      type = types.listOf types.str;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    # Enable settings that make nix/hm work better on _other_ distros
    targets.genericLinux.enable = true;

    # Install nixGL to run gfx programs like kitty
    home.packages = [nixGL nixVulkan];

    # Overlay nix packages with wrapped versions
    nixpkgs.overlays = let
      wrap = pkg: wrapper: let
        exe = getExe pkg;
        wrapperExe = getExe wrapper;
        wrapped = writeShellScriptBin (baseNameOf exe) ''
          exec -a "$0" ${wrapperExe} ${exe} "$@"
        '';
      in
        pkgs.symlinkJoin {
          name = pkg.pname;
          paths = [wrapped pkg];
        };
    in [
      (final: prev: {
        # TODO map over glPkgNames & vkPkgNames
        kitty = wrap prev.kitty nixGL;
      })
    ];
  };
}
