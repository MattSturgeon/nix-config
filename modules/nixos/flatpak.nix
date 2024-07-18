{ config, lib, ... }:
let
  cfg = config.custom.flatpak;
in
{
  options.custom.flatpak = {
    enable = lib.mkEnableOption "flatpak";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    # TODO: add repo in a systemd service
    # flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  };
}
