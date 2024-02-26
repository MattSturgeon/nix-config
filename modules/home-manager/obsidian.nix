{
  config,
  lib,
  ...
}: let
  inherit (lib) mapAttrsToList mkIf mkOption types;
  cfg = config.custom.obsidian;
  nvim = config.custom.editors.nvim;
in {
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
    # TODO need to enable unfree software to install Obsidian
    #   For now, using obsidian.nvim & the obsidian flatpak is ok...

    # TODO configure syncthing to sync obsidian vault

    # Setup obsidian.nvim if neovim is enabled
    programs.nixvim.plugins.obsidian = mkIf nvim {
      enable = true;
      workspaces = mapAttrsToList (name: path: {inherit name path;}) cfg.vaults;
    };
  };
}
