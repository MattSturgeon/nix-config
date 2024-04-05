{ config
, lib
, pkgs
, ...
}:
let
  inherit (lib) mapAttrsToList mkIf mkOption types;
  cfg = config.custom.obsidian;
  nvim = config.custom.editors.nvim;
in
{
  options.custom.obsidian = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Obsidian configuration";
    };
    vaults = mkOption {
      type = with types; attrsOf str; # FIXME consider using types.path
      description = "A set of Obsidian vaults. The attribute key is the vault name and the value is the path to the vault.";
      default = {
        "Notes" = "~/Documents/Notes";
      };
    };
  };

  config = mkIf cfg.enable {
    # TODO enable this seperately from obsidian.nvim?
    home.packages = with pkgs; [ obsidian ];

    home.sessionVariables = {
      # Enable wayland in electron
      NIXOS_OZONE_WL = 1;
    };

    # TODO obsidian vimrc

    # TODO move to standalone nixvim OR use nvim.nixvimExtend
    # Setup obsidian.nvim if neovim is enabled
    # programs.nixvim.plugins.obsidian = mkIf nvim {
    #   enable = true;
    #   settings.workspaces = mapAttrsToList (name: path: { inherit name path; }) cfg.vaults;
    # };

    # TODO configure syncthing to sync obsidian vault
  };
}
