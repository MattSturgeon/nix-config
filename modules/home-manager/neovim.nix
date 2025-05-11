{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption mkIf;
  cfg = config.custom.editors;
in
{
  options.custom.editors.nvim = mkOption {
    type = types.bool;
    default = true;
    description = "Use Neovim";
  };

  config = mkIf cfg.nvim {
    home.packages = [ self.packages.${pkgs.system}.nvim ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
