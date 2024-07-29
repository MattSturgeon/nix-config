{ pkgs, ... }: {
  viAlias = true;
  vimAlias = true;

  colorschemes.catppuccin = {
    enable = true;
    settings = {
      background.light = "macchiato";
      background.dark = "mocha";
    };
  };

  luaLoader.enable = true;
  editorconfig.enable = true;
  clipboard.providers.wl-copy.enable = true;

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

  # Only show lsp-lines on the current line
  diagnostics.virtual_lines.only_current_line = true;

  autoCmd = [
    {
      desc = "Highlight on yank";
      event = "TextYankPost";
      callback.__raw = /* lua */ ''
        function() vim.highlight.on_yank({ higroup="IncSearch", timeout=250 }) end
      '';
    }
  ];

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

    cmp = {
      enable = true;

      # Setting this means we don't need to explicitly enable
      # each completion source, so long as the plugin is listed
      # in https://github.com/nix-community/nixvim/blob/cd32dcd50fa98cd03e2916b6fd47e31deffbca24/plugins/completion/cmp/cmp-helpers.nix#L23
      autoEnableSources = true;

      settings = {
        mapping.__raw = /* lua */ ''
          cmp.mapping.preset.insert({
            ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Use first if none selected
            ["<C-CR>"] = cmp.mapping.confirm({ select = true }), -- C-y alias
            ["<CR>"] = cmp.mapping.confirm(), -- Return can confirm if selected
            ["<C-Space>"] = cmp.mapping.complete(), -- Open list without typing
          })
        '';

        sources = [
          {
            name = "emoji";
            groupIndex = 1;
          }
          {
            name = "nvim_lsp";
            groupIndex = 2;
          }
          {
            name = "treesitter";
            groupIndex = 2;
          }
          {
            name = "spell";
            groupIndex = 2;
          }
          {
            name = "luasnip";
            groupIndex = 3;
          }
        ];
      };

      filetype = {
        gitcommit = {
          sources = [
            { name = "conventionalcommits"; }
            { name = "git"; }
            { name = "emoji"; }
            { name = "path"; }
          ];
        };
      };

      cmdline =
        let
          common = {
            mapping.__raw = /* lua */ ''
              cmp.mapping.preset.cmdline({
                ["<C-Space>"] = cmp.mapping.complete(), -- Open list without typing
              })
            '';
            sources = [{ name = "buffer"; }];
          };
        in
        {
          "/" = common;
          "?" = common;
          ":" = {
            inherit (common) mapping;
            sources = [
              { name = "path"; }
              { name = "cmdline"; }
            ];
          };
        };
    };

    luasnip.enable = true; # TODO install snippets

    lsp = {
      enable = true;

      servers = {
        bashls.enable = true;
        html.enable = true;
        java-language-server.enable = true;
        lua-ls.enable = true;
        ruff-lsp.enable = true; # Python linter
        # Python type-checker
        pyright = {
          enable = true;
          settings = {
            # Disable ruff conflicts:
            pyright.disableOrganizeImports = true;
            python.analysis.ignore = [ "*" ];
          };
        };
        nixd = {
          # Nix LS
          enable = true;
          settings = {
            # TODO: we can define these if this flake is installed to
            # a consistent location.
            #
            # nixpkgs.expr = null;
            # options = {
            #   flake-parts.expr = null;
            #   home-manager.expr = null;
            #   nixvim.expr = null;
            # };
            diagnostic = {
              # Suppress noisy warnings
              suppress = [
                "sema-escaping-with"
                "var-bind-to-this"
              ];
            };
          };
        };
        hls.enable = true; # Haskell LS
        ccls.enable = true; # C/C++/ObjC LS
        #cangd.enable = true; # LLVM C/C++ LS
        gopls.enable = true; # Golang LS
        tsserver.enable = true; # TypeScript & JavaScript
        zls.enable = true; # Zig
        rust-analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
        };
      };
    };

    lsp-lines.enable = true;

    # Enable tmux-navigator
    tmux-navigator.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    vim-be-good # vim motions minigames
  ];
}
