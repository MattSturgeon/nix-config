{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkIf mkOption;
  cfg = config.custom.browsers;
in {
  options.custom.browsers = {
    firefox = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Firefox";
    };
  };

  config = mkIf cfg.firefox {
    programs = {
      firefox = {
        enable = true;
        package = pkgs.firefox-wayland;
        profiles.matt = {
          id = 0;
          name = "Matt Sturgeon";
          isDefault = true;
          search = {
            default = "google"; # TODO Move to something more privacy respecting?
            force = true; # Firefox often replaces the symlink, so force on update
          };
          # extensions = [ ]; # (some are packaged in NUR)
          # extraConfig = '' ''; # user.js
          # userChrome = '' ''; # chrome CSS
          # userContent = '' ''; # content CSS
        };
      };
    };

    home.packages = with pkgs; [
      fx_cast_bridge
    ];

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
