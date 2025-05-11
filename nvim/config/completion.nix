{
  plugins.cmp = {
    enable = true;

    # Setting this means we don't need to explicitly enable
    # each completion source, so long as the plugin is listed
    # in https://github.com/nix-community/nixvim/blob/cd32dcd50fa98cd03e2916b6fd47e31deffbca24/plugins/completion/cmp/cmp-helpers.nix#L23
    autoEnableSources = true;

    settings = {
      mapping.__raw = # lua
        ''
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
          mapping.__raw = # lua
            ''
              cmp.mapping.preset.cmdline({
                ["<C-Space>"] = cmp.mapping.complete(), -- Open list without typing
              })
            '';
          sources = [ { name = "buffer"; } ];
        };
      in
      {
        "/" = common;
        "?" = common;
        ":" = {
          inherit (common) mapping;
          sources = [
            {
              name = "path";
              option.trailing_slash = true;
            }
            { name = "cmdline"; }
          ];
        };
      };
  };
}
