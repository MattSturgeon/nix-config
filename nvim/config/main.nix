{ pkgs, ... }:
{
  viAlias = true;
  vimAlias = true;

  luaLoader.enable = true;
  editorconfig.enable = true;

  plugins = {
    lualine.enable = true;
    comment.enable = true;
    todo-comments.enable = true;
    web-devicons.enable = true;

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

    luasnip.enable = true; # TODO install snippets

    # Enable tmux-navigator
    tmux-navigator.enable = true;
  };
}
