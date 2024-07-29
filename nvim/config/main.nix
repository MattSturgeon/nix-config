{ pkgs, ... }: {
  viAlias = true;
  vimAlias = true;

  luaLoader.enable = true;
  editorconfig.enable = true;

  plugins = {
    lualine.enable = true;
    comment.enable = true;
    todo-comments.enable = true;

    refactoring = {
      enable = true;
      enableTelescope = true;
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

    luasnip.enable = true; # TODO install snippets

    # Enable tmux-navigator
    tmux-navigator.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    vim-be-good # vim motions minigames
  ];
}
