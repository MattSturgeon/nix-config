# TODO move most (all) of this to a common config module
{lib, ...}: {
  custom = {
    otherHost = {
      enable = true;
      glPackages = [
        "kitty"
        "jetbrains.idea-community"
      ];
    };
    gnome.favorites = lib.mkAfter ["com.heroicgameslauncher.hgl.desktop" "jetbrains-idea-ce.desktop"];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
