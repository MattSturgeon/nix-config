{ pkgs, ... }: {
  viAlias = true;
  vimAlias = true;

  luaLoader.enable = true;
  editorconfig.enable = true;

  # Only show lsp-lines on the current line
  diagnostics.virtual_lines.only_current_line = true;

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
