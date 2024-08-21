{ lib, ... }: {
  custom = {
    editors.vscode = true;
    editors.idea = true;
    gnome.favorites = lib.mkAfter [
      "com.heroicgameslauncher.hgl.desktop"
      "jetbrains-idea-ce.desktop"
    ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
