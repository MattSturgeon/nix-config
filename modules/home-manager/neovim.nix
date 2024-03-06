{
  config,
  lib,
  pkgs,
  nixvim,
  ...
}: let
  inherit (lib) types mkOption mkIf;
  cfg = config.custom.editors;
in {
  imports = [nixvim.homeManagerModules.nixvim];

  options.custom.editors.nvim = mkOption {
    type = types.bool;
    default = true;
    description = "Use Neovim";
  };

  config = mkIf cfg.nvim {
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

        luaLoader.enable = true;
        editorconfig.enable = true;
        clipboard.providers.wl-copy.enable = true;

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
          spell = true; # Enable spellcheck
          conceallevel = 2; # Enable syn-cchar replacements (for Obsidian)
        };

        keymaps = [
          {
            # Quick exit insert mode using `jj`
            mode = "i";
            key = "jj";
            action = "<Esc>";
            options.silent = true;
          }

          # Show which-key
          {
            mode = ["n" "v"];
            key = "<C- >";
            action = "<cmd>WhichKey<CR>";
            options.silent = true;
            options.desc = "Which Key";
          }

          # Window motions
          {
            mode = "n";
            key = "<leader>w";
            # Workaround which-key.nvim issue #583
            # Call :WhichKey manually, delegating <C-w>
            action = "<cmd>WhichKey <C-w><CR>";
            options.silent = true;
            options.desc = "+windows";
          }

          # Buffer motions
          {
            mode = "n";
            key = "<leader>bn";
            action = "<cmd>bn<CR>";
            options.silent = true;
            options.desc = "Go to next buffer";
          }
          {
            mode = "n";
            key = "<leader>bp";
            action = "<cmd>bp<CR>";
            options.silent = true;
            options.desc = "Go to previous buffer";
          }
        ];

        plugins = {
          fugitive.enable = true;
          lualine.enable = true;
          comment-nvim.enable = true;
          todo-comments.enable = true;

          which-key = {
            enable = true;
            registrations = {
              # Group names
              "<leader>b" = "+buffers";
            };
          };

          gitsigns = {
            enable = true;
            # The right alighed virtext was getting annoying; when the window is small it can clobber actual text!
            # Disable git blame for now
            currentLineBlame = false;
            # currentLineBlameOpts.virtTextPos = "right_align";
          };

          indent-blankline = {
            enable = true;
            indent.char = "¦";
          };

          mini = {
            enable = true;
            modules = {
              surround = {}; # ~ surround
              trailspace = {}; # Highlight/remove trailing whitespace
            };
          };

          nvim-autopairs.enable = true;

          telescope = {
            enable = true;
            extensions = {
              frecency.enable = true;
              fzf-native.enable = true;
              media_files.enable = true;
            };
            keymaps = {
              "<leader>bb" = {
                action = "buffers";
                desc = "List buffers";
              };
            };
          };

          treesitter = {
            enable = true;
            indent = true;
          };
          treesitter-context = {
            enable = true;
            maxLines = 4;
            minWindowHeight = 40;
          };

          nvim-cmp = {
            enable = true;
            mapping = {
              "<CR>" = /* lua */ "cmp.mapping.confirm({ select = true })";
              "C-y" = /* lua */ "cmp.mapping.confirm({ select = true })";
              "<Tab>" = {
                modes = ["i" "s"];
                action = /* lua */ ''
                  function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.expandable() then
                      luasnip.expand()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    elseif has_words_before() then
                      fallback()
                    else
                      fallback()
                    end
                  end
                '';
              };
              "<S-Tab>" = {
                modes = ["i" "s"];
                action = /* lua */ ''
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
              {
                name = "buffer";
                groupIndex = 4;
              }
              {
                name = "nvim_lsp";
                groupIndex = 2;
              }
              {
                name = "luasnip";
                groupIndex = 3;
              }
              {
                name = "treesitter";
                groupIndex = 2;
              }
              # { name = "dap"; groupIndex = 1; }
              # { name = "copilot"; groupIndex = 1; }
              {
                name = "git";
                groupIndex = 1;
              }
              {
                name = "conventionalcommits";
                groupIndex = 1;
              }
              {
                name = "spell";
                groupIndex = 2;
              }
              {
                name = "emoji";
                groupIndex = 1;
              }
            ];
          };

          luasnip.enable = true; # TODO install snippets

          lsp = {
            enable = true;

            # Bind keys to `vim.lsp.buf.*` functions:
            keymaps.lspBuf = {
              K = "hover";
              gD = "references";
              gd = "definition";
              gi = "implementation";
              gt = "type_definition";
            };

            servers = {
              bashls.enable = true;
              html.enable = true;
              java-language-server.enable = true;
              lua-ls.enable = true;
              nil_ls.enable = true; # Nix LS
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

          lsp-lines = {
            enable = true;
            currentLine = true;
          };
        };

        extraPlugins = with pkgs.vimPlugins; [
          vim-be-good # vim motions minigames
          vim-sleuth # tpope's indent fixes
        ];

        extraConfigLuaPre = /* lua */ ''
          -- Define some variables used in nvim-cmp keybinds
          -- as per the example on nvim-cmp's wiki
          local has_words_before = function()
            unpack = unpack or table.unpack
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
          end

          local luasnip = require("luasnip")
          local cmp = require("cmp")
        '';
      };
    };
  };
}
