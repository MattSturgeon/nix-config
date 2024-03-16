{ lib
, util
, config
, specialArgs
, ...
}:
let
  # Enabled users with home-manager configs
  users = lib.filterAttrs (_: user: user.enable && user.home-manager-config != null) config.custom.users;
in
{
  # Extend the custom.users submodule
  options.custom.users = lib.mkOption {
    type = with lib.types; attrsOf (submodule {
      options = {
        home-manager-config = lib.mkOption {
          type = with lib.types; nullOr deferredModule;
          default = null;
          description = "home-manager module for this user";
        };
      };
    });
  };

  config = {
    # Configure home-manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = specialArgs;

    # Assign home-manager user configs
    home-manager.users = builtins.mapAttrs (_: user: user.home-manager-config) users;
  };
}
