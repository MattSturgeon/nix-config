{ pkgs, ... }: {
  viAlias = true;
  vimAlias = true;

  luaLoader.enable = true;
  editorconfig.enable = true;

  plugins = {
    fugitive.enable = true;
    lualine.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    sleuth.enable = true; # tpope's indent fixes

    refactoring = {
      enable = true;
      enableTelescope = true;
    };

    gitsigns = {
      enable = true;
      settings.current_line_blame = false;
    };

    indent-blankline = {
      enable = true;
      settings.indent.char = "¦";
    };

    mini = {
      enable = true;
      modules = {
        surround = { }; # ~ surround
        trailspace = { }; # Highlight/remove trailing whitespace
      };
    };

    nvim-autopairs.enable = true;

    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
        media-files.enable = true;
      };
    };

    treesitter = {
      enable = true;
      settings.indent.enable = true;
    };
    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 4;
        min_window_height = 40;
      };
    };

    luasnip.enable = true; # TODO install snippets

    # Enable tmux-navigator
    tmux-navigator.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    vim-be-good # vim motions minigames
  ];
}
