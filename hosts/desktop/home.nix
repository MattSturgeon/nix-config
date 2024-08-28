{ lib, ... }: {
  custom = {
    editors.vscode = true;
    editors.idea = true;
    gnome.favorites = lib.mkAfter [
      "steam.desktop"
      "com.heroicgameslauncher.hgl.desktop"
      "org.prismlauncher.PrismLauncher.desktop"
      "idea-community.desktop"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
