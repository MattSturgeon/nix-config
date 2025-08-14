{ pkgs, ... }:
{
  config = {
    home.packages = with pkgs; [
      ripgrep
      nh
      tree
      jq
      wl-clipboard
    ];

    programs = {
      # Enable nix-index's command not found
      nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
      };
    };
  };
}
