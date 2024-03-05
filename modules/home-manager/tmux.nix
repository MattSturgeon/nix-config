{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption mkIf getExe;
  cfg = config.custom.tmux;
  nvim = config.custom.editors.nvim;
in {
  options.custom.tmux = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tmux";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      keyMode = "vi";
      mouse = true;
      baseIndex = 1; # Count sessions from 1
      newSession = true; # Spawn when failing to attach
      historyLimit = 10000;
      clock24 = true;
      shell = getExe config.programs.fish.package; # Use fish shell
      # TODO set leader key using `shortcut` or `prefix`
      terminal = "screen-256color"; # Enable 256bit color

      plugins = with pkgs.tmuxPlugins;
        [
          sensible
          catppuccin
        ]
        ++ (
          # Enable tmux-navigator if using vim
          if nvim
          then [vim-tmux-navigator]
          else []
        );

      extraConfig = ''
        # TODO
      '';
    };

    # Enable tmux-navigator in vim too
    programs.nixvim.plugins.tmux-navigator.enable = true;
  };
}
