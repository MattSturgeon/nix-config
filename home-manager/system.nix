{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    tree
    zellij # TODO configure
  ];

}
