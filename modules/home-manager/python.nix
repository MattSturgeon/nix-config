{ pkgs, ... }:
{
  home.packages = with pkgs; [
    poetry
  ];
}
