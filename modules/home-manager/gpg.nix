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
      # TODO make this platform-dependant
      # TODO use gcr_4
      pinentry.package = pkgs.pinentry-gnome3;
      grabKeyboardAndMouse = true;
      sshKeys = [
        "EC516C4E1E481414EBDE388868B6F9F70B6727FD"
      ];
    };

    xdg = {
      enable = true;
      # Disable gnome-keyring's ssh-agent
      # TODO make this platform-dependant
      configFile."autostart/gnome-keyring-ssh.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Hidden=true
      '';
    };
  };

  # TODO configure git signing key?
  # TODO gnome's keyring conflicts with gpg-agent
}
