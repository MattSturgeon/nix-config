{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.docker;
in
{
  options.custom.docker.enable = lib.mkEnableOption "docker";

  config = lib.mkIf cfg.enable {
    users.users.matt = {
      extraGroups = [
        "docker"
        "podman"
      ];
    };

    virtualisation = {
      podman = {
        enable = true;

        # prune images and containers periodically
        autoPrune = {
          enable = true;
          flags = [ "--all" ];
          dates = "weekly";
        };

        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    environment.systemPackages = [
      pkgs.podman-compose
    ];
  };
}
