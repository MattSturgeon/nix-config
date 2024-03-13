{ lib
, util
, config
, specialArgs
, ...
}:
let
  # username -> user -> {username=hmConfig}
  toPair = username: _:
    with builtins;
    let
      file = getHomeConfig username;
      found =
        assert readFileType file == "regular";
        trace ''Found home-manager config for "${username}": ${toString file}'';
      notFound =
        trace ''No home-manager config found for "${username}". Not found: ${toString file}'';
    in
    if pathExists file then found { ${username} = file; } else notFound { };

  # Wrap util's `getHomeConfig`, using the system hostname
  getHomeConfig = util.system.getHomeConfig config.networking.hostName;

  # Enabled users
  users = lib.filterAttrs (_: user: user.enable) config.custom.users;
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
    # TODO pass user-info into home-manager modules
    # TODO get config from ../../home/user@host and ../../home/user
    home-manager.users = builtins.mapAttrs (_: user: user.home-manager-config) users;
  };
}
