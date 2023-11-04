{pkgs, ...}: {
  config = {
    home.packages = with pkgs; [
      tree
      wl-clipboard
    ];
  };
}
