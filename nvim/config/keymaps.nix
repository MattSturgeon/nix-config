{ helpers, ... }:
let
  # TODO: use the upcoming `plugins.which-key.settings` options
  registrations = [
    {
      __unkeyed-1 = "<leader>w";
      proxy = "<C-w>";
      group = "windows";
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
in
{
  plugins.which-key = {
    enable = true;
    # registrations added manually in extraConfigLua
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
      mode = [ "n" "v" ];
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
      action = "<cmd>bd<CR>";
      options.desc = "Delete the current buffer";
    }

    # Refactoring
    {
      mode = "n";
      key = "<leader>rr";
      action.__raw = /* lua */ ''
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
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "telescope_project_files()";
      options.desc = "Find files";
    }
  ];

  plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>bb" = {
        action = "buffers";
        options.desc = "List buffers";
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
      gr = {
        action = "references";
        desc = "Show references";
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

  # TODO: use the upcoming `plugins.which-key.settings` options
  extraConfigLua = /* lua */ ''
    -- Register which-key groups
    require('which-key').add(${helpers.toLuaObject registrations})
  '';

  extraConfigLuaPre = /* lua */ ''
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
