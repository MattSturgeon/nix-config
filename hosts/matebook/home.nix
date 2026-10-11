{ lib, pkgs, ... }:
{
  custom = {
    editors.vscode = true;
    editors.idea.enable = true;
    gnome.favorites = lib.mkAfter [
      "org.prismlauncher.PrismLauncher.desktop"
      pkgs.intellij-idea.desktopItem.name
    ];
  };

  # TODO can state version be centralised?
  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
