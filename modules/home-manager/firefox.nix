{ config
, lib
, util
, pkgs
, inputs
, ...
}:
let
  inherit (lib) types mkIf mkOption;
  inherit (util.modules) mkFirst;
  cfg = config.custom.browsers.firefox;
  otherHost = config.custom.otherHost.enable;

  # Rycee firefox-addons packages
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system};
in
{
  options.custom.browsers.firefox = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Firefox config";
    };
    install = mkOption {
      type = types.bool;
      # By default, only install the actual browres on NixOS hosts
      default = !otherHost;
      description = "Install the actual browser";
    };
    desktopName = mkOption {
      type = with types; nullOr str;
      default =
        # The nix build of firefox uses "firefox.desktop".
        # If we're not installing the actual browser, assume
        # the flatpak version will be used.
        if cfg.install
        then "firefox.desktop"
        else "org.mozilla.firefox.desktop";
      description = ''The firefox desktop file to add to "favorites", or null'';
      defaultText = ''"firefox.desktop" when `install` is true, otherwise "org.mozilla.firefox.desktop"'';
    };
  };

  config = mkIf cfg.enable {
    custom.gnome = {
      # Add desktop entry to gnome favorites
      favorites = mkIf (cfg.desktopName != null) (mkFirst [ cfg.desktopName ]);
    };

    programs = {
      firefox = {
        enable = true;
        package =
          if cfg.install
          then pkgs.firefox-wayland
          else null;
        profiles.matt = {
          id = 0;
          name = "Matt Sturgeon";
          isDefault = true;

          extensions = with firefox-addons; [
            darkreader
            refined-github
            violentmonkey
            privacy-badger
          ];

          search = {
            default = "duckduckgo";
            force = true; # Firefox often replaces the symlink, so force on update
          };

          settings = {
            # Disable about:config warning
            "browser.aboutConfig.showWarning" = false;

            # Mozilla telemetry
            "toolkit.telemetry.enabled" = true;

            # Homepage settings
            # 0 = blank, 1 = home, 2 = last visited page, 3 = resume previous session
            "browser.startup.page" = 1;
            "browser.startup.homepage" = "about:home";
            "browser.newtabpage.enabled" = true;
            "browser.newtabpage.activity-stream.topSitesRows" = 2;
            "browser.newtabpage.storageVersion" = 1;
            "browser.newtabpage.pinned" = [
              {
                "label" = "GitHub";
                "url" = "https://github.com";
              }
              {
                "label" = "YouTube";
                "url" = "https://youtube.com";
              }
              {
                "label" = "YT Music";
                "url" = "https://music.youtube.com";
              }
              {
                "label" = "Monkeytype";
                "url" = "https://monkeytype.com";
              }
            ];

            # Activity Stream
            "browser.newtab.preload" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = true;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "browser.newtabpage.activity-stream.default.sites" = "";

            # Addon recomendations
            "browser.discovery.enabled" = false;
            "extensions.getAddons.showPane" = false;
            "extensions.htmlaboutaddons.recommendations.enabled" = false;

            # Crash reports
            "breakpad.reportURL" = "";
            "browser.tabs.crashReporting.sendReport" = false;

            # Auto-decline cookies
            "cookiebanners.service.mode" = 2;
            "cookiebanners.service.mode.privateBrowsing" = 2;

            # Disable autoplay
            "media.autoplay.default" = 5;

            # Prefer dark theme
            "layout.css.prefers-color-scheme.content-override" = 0; # 0: Dark, 1: Light, 2: Auto

            # HTTPS only
            "dom.security.https_only_mode" = true;

            # Trusted DNS (TRR)
            "network.trr.mode" = 2;
            "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

            # ECH - prevent TLS connections leaking request hostname
            "network.dns.echconfig.enabled" = true;
            "network.dns.http3_echconfig.enabled" = true;

            # Tracking
            "browser.contentblocking.category" = "strict";
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.pbmode.enabled" = true;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.trackingprotection.cryptomining.enabled" = true;
            "privacy.trackingprotection.fingerprinting.enabled" = true;

            # Fingerprinting
            "privacy.fingerprintingProtection" = true;
            "privacy.resistFingerprinting" = true;
            "privacy.resistFingerprinting.pbmode" = true;

            "privacy.firstparty.isolate" = true;

            # URL query tracking
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.enabled.pbmode" = true;

            # Prevent WebRTC leaking IP address
            "media.peerconnection.ice.default_address_only" = true;

            # Use Mozilla geolocation service instead of Google
            "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";

            # Disable password manager   TODO Transition to 1password
            # "signon.rememberSignons" = false;
            # "signon.autofillForms" = false;
            # "signon.formlessCapture.enabled" = false;

            # Hardens against potential credentials phishing:
            # 0 = don’t allow sub-resources to open HTTP authentication credentials dialogs
            # 1 = don’t allow cross-origin sub-resources to open HTTP authentication credentials dialogs
            # 2 = allow sub-resources to open HTTP authentication credentials dialogs (default)
            "network.auth.subresource-http-auth-allow" = 1;
          };

          # extraConfig = '' ''; # user.js
          # userChrome = '' ''; # chrome CSS
          # userContent = '' ''; # content CSS
        };
      };
    };

    home.sessionVariables = {
      # This should be default soon
      MOZ_ENABLE_WAYLAND = 1;

      # Non-nix firefox crashes without this because profiles.ini is read-only
      MOZ_LEGACY_PROFILES = 1;
    };
  };
}
