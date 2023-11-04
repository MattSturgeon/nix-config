{lib, ...}: {
  custom = {
    boot.splash = true;
    desktop.gnome = true;
  };

  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["vscode" "vscode-extension-github-codespaces" "vscode-extension-ms-vscode-cpptools"];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
