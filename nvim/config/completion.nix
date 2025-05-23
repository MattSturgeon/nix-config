{
  lib,
  config,
  pkgs,
  ...
}:
let
  blinkCfg = config.plugins.blink-cmp;
in
{

  # Install additional sources
  plugins.blink-emoji.enable = blinkCfg.enable;
  plugins.blink-cmp-git.enable = blinkCfg.enable;
  extraPlugins =
    with pkgs.vimPlugins;
    lib.mkIf blinkCfg.enable [
      blink-cmp-conventional-commits
    ];

  # Dependencies
  extraPackages = lib.mkIf (blinkCfg.enable && config.plugins.blink-cmp-git.enable) [
    # Needed by blink-cmp-git
    # TODO: upstream to nixvim's dependencies system
    pkgs.gh
  ];

  # Configure blink
  plugins.blink-cmp = {
    enable = true;

    # See https://cmp.saghen.dev
    settings = {
      keymap.preset = "default";
      completion = {
        documentation.auto_show = true;
      };

      sources = {
        # Enable sources
        default = [
          # defaults
          "lsp"
          "path"
          "snippets"
          # "buffer"

          # plugins
          "conventional_commits"
          "emoji"
          "git"
        ];

        # Can also enable sources per-filetype
        # per_filetype.<ft> = [];

        # Define extra providers
        # TODO: handle this better in nixvim
        providers = {
          # plugins.blink-cmp
          emoji = {
            name = "Emoji";
            module = "blink-emoji";
            score_offset = 15;
            opts = {
              insert = true;
            };
          };

          # plugins.blink-cmp-git
          git = {
            name = "git";
            module = "blink-cmp-git";
            score_offset = 100;
            opts = {
              commit = {
                # Default trigger ":" conflicts with blink-emoji
                triggers = [ "~" ];
              };
              git_centers = {
                git_hub = { };
              };
            };
          };

          # vimPlugins.blink-cmp-conventional-commits
          # https://github.com/disrupted/blink-cmp-conventional-commits/
          conventional_commits = {
            name = "Conventional Commits";
            module = "blink-cmp-conventional-commits";
            enabled.__raw = # lua
              ''
                function()
                  return vim.bo.filetype == 'gitcommit'
                end
              '';
          };
        };
      };
    };
  };

}
