{ config
, lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib) types mkOption mkIf getExe;
  inherit (lib.generators) toYAML;
  cfg = config.custom.tmux;
  nvim = config.custom.editors.nvim;

  # Make a tmux plugin, with optional extraConfig
  mkPlugin = attrs:
    let
      plugin = pkgs.tmuxPlugins.mkTmuxPlugin attrs;
    in
    if (lib.hasAttr "extraConfig" attrs)
    then {
      inherit plugin;
      inherit (attrs) extraConfig;
    }
    else plugin;

  extraPlugins = map mkPlugin [
    {
      pluginName = "tmux-which-key";
      version = inputs.tmux-which-key.shortRev;
      src = inputs.tmux-which-key;
      rtpFilePath = "plugin.sh.tmux";
      extraConfig = ''
        # Use XDG config file for which-key plugin
        set -g @tmux-which-key-xdg-enable 1;
      '';
    }
  ];
in
{
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
      escapeTime = 0; # Prevent Esc delay
      baseIndex = 1; # Count sessions from 1
      newSession = true; # Spawn when failing to attach
      historyLimit = 10000;
      clock24 = true;
      shell = getExe config.programs.fish.package; # Use fish shell
      # TODO set leader key using `shortcut` or `prefix`
      terminal = "screen-256color"; # Enable 256bit color

      plugins = with pkgs.tmuxPlugins;
        [
          catppuccin
        ]
        ++ extraPlugins
        ++ (
          # Enable tmux-navigator if using vim
          if nvim
          then [ vim-tmux-navigator ]
          else [ ]
        );

      extraConfig = ''
        # TODO
      '';
    };

    xdg.configFile = {
      "tmux/plugins/tmux-which-key/config.yaml".text = toYAML { } {
        command_alias_start_index = 200;
      };
    };

    # Enable tmux-navigator in vim too
    programs.nixvim.plugins.tmux-navigator.enable = true;
  };
}
