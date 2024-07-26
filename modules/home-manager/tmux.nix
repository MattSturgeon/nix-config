{ config
, lib
, pkgs
, inputs
, ...
}:
let
  inherit (lib) types mkOption mkIf getExe;
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
        # Set new panes to open in current directory
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Same, for now windows
        # bind c new-window -c "#{pane_current_path}"

        # Move status bar to the top
        set-option -g status-position top
      '';
    };

    xdg.configFile = {
      "tmux/plugins/tmux-which-key/config.yaml".source = pkgs.writers.writeYAML "tmux-which-key-config" {
        command_alias_start_index = 200;
      };
    };
  };
}
