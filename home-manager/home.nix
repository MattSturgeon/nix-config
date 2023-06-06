{ config, pkgs, ... }:

{
  # FIXME define user info in a central location
  home.username = "matt";
  home.homeDirectory = "/home/matt";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # TODO add some pakages
  ];

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Git
    git = {
      enable = true;
    };
  };

  # Reload system services when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
