{ lib, ... }:
{
  custom = {
    editors.vscode = true;
    editors.idea = true;
    editors.android = true;
    gnome.favorites = lib.mkAfter [
      "steam.desktop"
      "com.heroicgameslauncher.hgl.desktop"
      "org.prismlauncher.PrismLauncher.desktop"
      "com.nexusmods.app.desktop"
      "idea-community.desktop"
      "android-studio.desktop"
    ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
