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
            default = "duckduckgo";
            force = true; # Firefox often replaces the symlink, so force on update
          };
          extensions = with config.nur.repos.rycee.firefox-addons; [
            darkreader
            refined-github
            violentmonkey
            privacy-badger
            istilldontcareaboutcookies
          ];
          # extraConfig = '' ''; # user.js
          # userChrome = '' ''; # chrome CSS
          # userContent = '' ''; # content CSS
        };
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
