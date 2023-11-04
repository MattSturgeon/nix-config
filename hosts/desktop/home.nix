# TODO move most (all) of this to a common config module
{...}: {
  custom = {
    otherHost = {
      enable = true;
      glPackages = ["kitty"];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
