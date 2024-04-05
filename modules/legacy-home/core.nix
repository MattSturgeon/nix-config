{ pkgs, ... }: {
  config = {
    home.packages = with pkgs; [
      ripgrep
      tree
      wl-clipboard
    ];
  };
}
