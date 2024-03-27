{ config, lib, pkgs, ... }:
let
  # Time units
  m = 60;
  h = 60 * m;
  d = 24 * h;
  y = 365 * d;
in
{
  config = {
    programs.gpg = {
      enable = true;
      settings = {
        default-key = "7082 22EA 1808 E39A 83AC  8B18 4F91 844C ED1A 8299";
      };
    };

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      defaultCacheTtl = 8 * h;
      defaultCacheTtlSsh = 8 * h;
      maxCacheTtl = 128 * y;
      maxCacheTtlSsh = 128 * y;
      pinentryPackage = if config.gtk.enable then pkgs.gcr_4 else pkgs.pinentry-curses;
      grabKeyboardAndMouse = true;
    };
  };

  # TODO configure git signing key?
  # TODO gnome's keyring conflicts with gpg-agent
}
