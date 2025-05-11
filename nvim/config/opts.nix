{
  clipboard.providers.wl-copy.enable = true;

  autoCmd = [
    {
      desc = "Highlight on yank";
      event = "TextYankPost";
      callback.__raw = # lua
        ''
          function() vim.highlight.on_yank({ higroup="IncSearch", timeout=250 }) end
        '';
    }
  ];

  globals = {
    mapleader = " ";
  };

  opts = {
    number = true; # Line numbers
    relativenumber = true; # ^Relative
    shiftwidth = 4; # Tab width
    smartindent = true;
    cursorline = true; # Highlight the current line
    scrolloff = 8; # Ensure there's at least 8 lines around the cursor
    title = true; # Let vim set the window title
    spell = true; # Enable spellcheck
    conceallevel = 2; # Enable syn-cchar replacements (for Obsidian)
  };
}
