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
          settings = {
            "browser.aboutConfig.showWarning" = false;
            "cookiebanners.service.mode" = 2;
            "cookiebanners.service.mode.privateBrowsing" = 2;
          };
          extensions = with config.nur.repos.rycee.firefox-addons; [
            darkreader
            refined-github
            violentmonkey
            privacy-badger
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
