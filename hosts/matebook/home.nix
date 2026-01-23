{ lib, ... }:
{
  custom = {
    editors.vscode = true;
    editors.idea = true;
    gnome.favorites = lib.mkAfter [
      "org.prismlauncher.PrismLauncher.desktop"
      "idea.desktop"
    ];
  };

  # TODO can state version be centralised?
  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
