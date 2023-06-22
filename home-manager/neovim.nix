{ config, pkgs, ... }: {

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs = {
    nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      colorschemes.catppuccin = {
        enable = true;
        background.light = "macchiato";
        background.dark = "mocha";
      };
      globals = {
        mapleader = " ";
      };
      options = {
        number = true; # Line numbers
	relativenumber = true; # ^Relative
	shiftwidth = 4; # Tab width
	smartindent = true;
	cursorline = true; # Highlight the current line
	scrolloff = 8; # Ensure there's at least 8 lines around the cursor
	title = true; # Let vim set the window title
      };
      maps = {
        # Better up/down movement
        normalVisualOp."j" = {
	  action = "v:count == 0 ? 'gj' : 'j'";
	  expr = true;
	  silent = true;
	};
        normalVisualOp."k" = {
          action = "v:count == 0 ? 'gk' : 'k'";
	  expr = true;
	  silent = true;
	};

        # Better window motions
        normal."<C-h>" = {
	  action = "<C-w>h";
	  desc = "Go to left window";
        };
        normal."<C-j>" = {
          action = "<C-w>j";
	  desc = "Go to lower window";
        };
        normal."<C-k>" = {
          action = "<C-w>k";
	  desc = "Go to upper window";
        };
        normal."<C-l>" = {
          action = "<C-w>l";
	  desc = "Go to right window";
        };
      };
      plugins = {
        which-key.enable = true;
	bufferline.enable = true;
	lualine.enable = true;
	gitsigns.enable = true;
	indent-blankline = {
	  enable = true;
	  charList = [ "¦" ];
          charListBlankline = [ "↵" ];
	  useTreesitter = true;
	};
	treesitter = {
	    enable = true;
	    indent = true;
	    nixvimInjections = true; # Highlight lua in NixVim config
	};
	treesitter-context.enable = true; # Prevent context from scrolling off screen (e.g. function declaration)
	nvim-cmp = {
	  enable = true;
	  mapping = {
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = {
              modes = [ "i" "s" ];
              action = ''
                function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expandable() then
                    luasnip.expand()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  elseif check_backspace() then
                    fallback()
                  else
                    fallback()
                  end
                end
              '';
            };
	  };
	};
	cmp-buffer.enable = true;
	#cmp_luasnip.enable = true;
	cmp-treesitter.enable = true;
	#cmp-nvim-lsp.enable=true;
	#cmp-dap.enable = true;
        #cmp-copilot.enable = true;
	cmp-git.enable = true; # GitHub/GitLab issue/pr completion
	cmp-conventionalcommits.enable = true;
	cmp-spell.enable = true;
	cmp-emoji.enable = true;
      };
    };
  };

}
