{ pkgs, ... }: {
  config = {
    home.packages = with pkgs; [
      ripgrep
      tree
      jq
      wl-clipboard
    ];
  };
}
