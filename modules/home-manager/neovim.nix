{
  self,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types mkOption mkIf;
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.custom.editors;
in
{
  options.custom.editors.nvim = mkOption {
    type = types.bool;
    default = true;
    description = "Use Neovim";
  };

  config = mkIf cfg.nvim {
    home.packages = [ self.packages.${system}.nvim ];
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
