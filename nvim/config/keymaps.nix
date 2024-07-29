{
  plugins.which-key = {
    enable = true;
    registrations = {
      # Group names
      "<leader>b" = "+buffers";
      "<leader>r" = "+refactoring";
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
      mode = [ "n" "v" ];
      key = "<C-Space>";
      action = "<cmd>WhichKey<CR>";
      options.desc = "Which Key";
    }

    # Window motions
    {
      mode = "n";
      key = "<leader>w";
      # Workaround which-key.nvim issue #583
      # Call :WhichKey manually, delegating <C-w>
      action = "<cmd>WhichKey <C-w><CR>";
      options.desc = "+windows";
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
}
