{
  config,
  lib,
  pkgs,
  nixgl,
  ...
}: let
  inherit (builtins) baseNameOf;
  inherit (lib) types getExe splitString getAttrFromPath setAttrByPath mkIf mkEnableOption mkOption;

  cfg = config.custom.otherHost;

  # Wraps a package with a nixgl wrapper, using symlinkJoin
  wrapPkg = wrapper: pkg: let
    exe = getExe pkg;
    wrapped = pkgs.writeShellScriptBin (baseNameOf exe) ''
      exec -a "$0" ${getExe wrapper} ${exe} "$@"
    '';
  in
    pkgs.symlinkJoin {
      name = pkg.pname;
      paths = [wrapped pkg];
    };

  # Maps a list of packages into a list of overlays
  mkOverlays = wrapper: packages: let
    # f maps `pkg` to an overlay function
    # The overlay function returned will wrap the given pkg with wrapper
    f = pkg: final: prev: let
      path = splitString "." pkg;
      base = getAttrFromPath path prev;
      wrapped = wrapPkg wrapper base;
    in
      setAttrByPath path wrapped;
  in
    map f packages;
in {
  options.custom.otherHost = {
    enable = mkEnableOption "Enable settings for non-NixOS hosts";

    command = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Install NixGL wrapper commands";
    };

    glWrapper = mkOption {
      type = types.package;
      default = pkgs.nixgl.nixGLIntel;
      description = "The NixGL package to use for wrapping OpenGL";
    };

    vkWrapper = mkOption {
      type = types.package;
      default = pkgs.nixgl.nixVulkanIntel;
      description = "The NixGL package to use for wrapping Vulkan";
    };

    glPackages = mkOption {
      # Must be [str] to avoid infinite recursion
      type = types.listOf types.str;
      default = [];
      description = "A list of package attributes in nixpkgs which should be wrapped using glWrapper";
    };

    vkPackages = mkOption {
      # Must be [str] to avoid infinite recursion
      type = types.listOf types.str;
      default = [];
      description = "A list of package attributes in nixpkgs which should be wrapped using vkWrapper";
    };
  };

  config = mkIf cfg.enable {
    # Enable settings intended for non-NixOS systems
    targets.genericLinux.enable = true;

    # Install nixGL wrapper commands to run things manually
    home.packages = with cfg;
      if command
      then [glWrapper vkWrapper]
      else [];

    # Overlay configured packages with wrapped versions
    nixpkgs.overlays = with cfg; [nixgl.overlay] ++ (mkOverlays glWrapper glPackages) ++ (mkOverlays vkWrapper vkPackages);
  };
}
