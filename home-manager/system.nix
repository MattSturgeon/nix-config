{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    fish # TODO configure
    tree
    zellij # TODO configure
  ];

}
