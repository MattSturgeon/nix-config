{ ... }: {
  custom = {
    gaming = true;
    editors.vscode = true;
    editors.idea = true;
  };

  # TODO can state version be centralised?
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
