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
	clipboard.providers.wl-copy = true;
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
            "C-y" = "cmp.mapping.confirm({ select = true })";
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
            "<S-Tab>" = {
              modes = [ "i" "s" ];
              action = ''
                function(fallback)
		  if cmp.visible() then
                    cmp.select_prev_item()
                  elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                  else
                    fallback()
                  end
                end
              '';
            };
	  };

          # Setting this means we don't need to explicitly enable
	  # each completion source, so long as the plugin is listed
          # in https://github.com/pta2002/nixvim/blob/794356625c19e881b4eae3bbbb078f3299f5c81d/plugins/completion/nvim-cmp/cmp-helpers.nix#L22
	  autoEnableSources = true; 
	  sources = [
	    { name = "buffer"; groupIndex = 4; }
	    { name = "nvim_lsp"; groupIndex = 2; }
	    { name = "luasnip"; groupIndex = 3; }
	    { name = "treesitter"; groupIndex = 2; }
	    # { name = "dap"; groupIndex = 1; }
            # { name = "copilot"; groupIndex = 1; }
	    { name = "git"; groupIndex = 1; }
	    { name = "conventionalcommits"; groupIndex = 1; }
	    { name = "spell"; groupIndex = 2; }
	    { name = "emoji"; groupIndex = 1; }
	  ];
	};

        luasnip.enable = true; # TODO install snippets
      };
    };
  };

}
