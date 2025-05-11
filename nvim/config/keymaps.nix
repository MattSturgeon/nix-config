{
  plugins.which-key = {
    enable = true;
    settings = {
      spec = [
        {
          __unkeyed-1 = "<leader>w";
          proxy = "<C-w>";
          group = "windows";
        }
        {
          __unkeyed-1 = "<c-w>c";
          desc = "Close current window";
        }
        {
          __unkeyed-1 = "<c-w>H";
          desc = "Move current window to the far left";
        }
        {
          __unkeyed-1 = "<c-w>J";
          desc = "Move current window to the very bottom";
        }
        {
          __unkeyed-1 = "<c-w>K";
          desc = "Move current window to the very top";
        }
        {
          __unkeyed-1 = "<c-w>L";
          desc = "Move current window to the far right";
        }

        {
          __unkeyed-1 = "<leader>b";
          group = "buffers";
        }

        {
          __unkeyed-1 = "<leader>r";
          group = "refactoring";
        }

        {
          __unkeyed-1 = "<leader>f";
          group = "files";
        }
      ];
      # Using telescope for spelling
      plugins.spelling.enabled = false;
    };
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
      mode = [
        "n"
        "v"
      ];
      key = "<C-Space>";
      action = "<cmd>WhichKey<CR>";
      options.desc = "Which Key";
    }

    # Buffers
    {
      mode = "n";
      key = "<leader>bn";
      action = "<cmd>bn<CR>";
      options.desc = "Go to next buffer";
    }
    {
      mode = "n";
      key = "<leader>bp";
      action = "<cmd>bp<CR>";
      options.desc = "Go to previous buffer";
    }
    {
      mode = "n";
      key = "<leader>bd";
      action = "<cmd>Bdelete<CR>";
      options.desc = "Delete the current buffer";
    }

    # Refactoring
    {
      mode = "n";
      key = "<leader>rr";
      action.__raw = # lua
        ''
          require("telescope").extensions.refactoring.refactors
        '';
      options.desc = "Select refactor";
    }
    {
      mode = "n";
      key = "<leader>re";
      action = ":Refactor extract_var ";
      options.desc = "Extract to variable";
    }
    {
      mode = "n";
      key = "<leader>rE";
      action = ":Refactor extract ";
      options.desc = "Extract to function";
    }
    {
      mode = "n";
      key = "<leader>rb";
      action = ":Refactor extract_block ";
      options.desc = "Extract to block";
    }
    {
      mode = "n";
      key = "<leader>ri";
      action = ":Refactor inline_var ";
      options.desc = "Inline variable";
    }
    {
      mode = "n";
      key = "<leader>rI";
      action = ":Refactor inline_func ";
      options.desc = "Inline function";
    }

    # Errors/diagnostics
    {
      mode = "n";
      key = "ge";
      action.__raw = "vim.diagnostic.goto_next";
      options.desc = "Goto next diagnostic";
    }
    {
      mode = "n";
      key = "gE";
      action.__raw = "vim.diagnostic.goto_prev";
      options.desc = "Goto previous diagnostic";
    }

    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "telescope_project_files()";
      options.desc = "Find files";
    }

    {
      mode = "n";
      key = "z=";
      action.__raw = ''
        function()
          require('telescope.builtin').spell_suggest(
            require('telescope.themes').get_cursor({ })
          )
        end
      '';
      options.desc = "Spelling suggestions";
    }
  ];

  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>bb" = {
        action = "buffers ignore_current_buffer=true sort_mru=true";
        options.desc = "List buffers";
      };
      "<leader>h" = {
        action = "help_tags";
        options.desc = "Browse help";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Grep files";
      };
      "<leader>`" = {
        action = "marks";
        options.desc = "Browse marks";
      };
      "<leader>\"" = {
        action = "registers";
        options.desc = "Browse registers";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Git status";
      };
      "gr" = {
        action = "lsp_references";
        options.desc = "Browse references";
      };
      "gA" = {
        action = "diagnostics";
        options.desc = "Browse diagnostics";
      };
      "gs" = {
        action = "treesitter";
        options.desc = "Browse symbols";
      };
    };
  };

  plugins.lsp.keymaps = {
    # See :h lsp-buf
    lspBuf = {
      K = {
        action = "hover";
        desc = "Show documentation";
      };
      gd = {
        action = "definition";
        desc = "Goto definition";
      };
      gD = {
        action = "declaration";
        desc = "Goto declaration";
      };
      gi = {
        action = "implementation";
        desc = "Goto implementation";
      };
      gt = {
        # FIXME conflicts with "next tab page" :h gt
        action = "type_definition";
        desc = "Goto type definition";
      };
      ga = {
        action = "code_action";
        desc = "Show code actions";
      };
      "g*" = {
        action = "document_symbol";
        desc = "Show document symbols";
      };
      "<leader>rn" = {
        action = "rename";
        desc = "Rename symbol";
      };
    };
  };

  # Provides a `:bd` alternative that doesn't change window layout
  plugins.bufdelete.enable = true;

  extraConfigLuaPre = # lua
    ''
      -- Helper for telescope (<leader>ff)
      function telescope_project_files()
        -- We cache the results of "git rev-parse"
        -- Process creation is expensive in Windows, so this reduces latency
        local is_inside_work_tree = {}

        local opts = {}

        return function()
          local cwd = vim.fn.getcwd()
          if is_inside_work_tree[cwd] == nil then
            vim.fn.system("git rev-parse --is-inside-work-tree")
            is_inside_work_tree[cwd] = vim.v.shell_error == 0
          end

          if is_inside_work_tree[cwd] then
            require("telescope.builtin").git_files(opts)
          else
            require("telescope.builtin").find_files(opts)
          end
        end
      end
    '';
}
