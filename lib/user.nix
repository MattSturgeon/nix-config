{
  lib,
  util,
  ...
}: let
  inherit (builtins) elem map listToAttrs toString length head baseNameOf filter;
  inherit (lib) unique;
  inherit (util.util) nixChildren;

  # Groups to be added to all admin users
  adminGroups = ["wheel" "networkmanager"];

  # Return the path to either 'home.nix' or '<username>.nix' in 'dir'.
  # If neither or both exist, the function will abort.
  getHomeConfig = dir: username: let
    count = length matches;
    chilren = nixChildren dir;
    matches = filter (file: elem (baseNameOf file) ["home.nix" (username + ".nix")]) chilren;
  in
    # Return the path to the (only) match
    # Abort if there isn't exactly one match
    if count == 1
    then head matches
    else if count > 1
    then abort "Multiple home files (${toString count}) found for ${username} in ${dir}"
    else abort "No valid home file found for ${username} in ${dir}";

  # Creates a copy of the provided attrset, ensuring all attributes are defined
  initUser = {
    name,
    description ? "",
    home ? "/home/${name}",
    isNormalUser ? true,
    isAdmin ? true,
    groups ? [],
    allowedKeys ? [],
    initialPassword ? "",
  }: {
    inherit name description home isNormalUser initialPassword allowedKeys;
    extraGroups = unique (groups
      ++ (
        if isAdmin
        then adminGroups
        else []
      ));
  };

  # Build a user as per NixOS users.users."name"'s schema
  mkNixOSUser = attrs: let
    user = initUser attrs;
  in
    {
      inherit (user) description home isNormalUser extraGroups;
    }
    // (
      if (length user.allowedKeys) == 0
      then {}
      else {
        openssh.authorizedKeys.keys = user.allowedKeys;
      }
    )
    // (
      if user.initialPassword == ""
      then {}
      else {inherit (user) initialPassword;}
    );

  # Build a NixOS module to configer the user
  mkNixOSUserModule = users: let
    cfg =
      listToAttrs
      (map
        (user: {
          inherit (user) name;
          value = mkNixOSUser user;
        })
        users);
  in (
    if (length users) == 0
    then {}
    else {
      users.users = cfg;
    }
  );

  # Build a Home Manager module to configure the user
  mkHMUserModule = user: let
    fUser = initUser user;
  in {
    home.username = fUser.name;
    home.homeDirectory = fUser.home;
  };

  # Build a NixOS module to enable each user's Home Manager config
  mkNixOSHMModule = path: users: let
    cfg =
      listToAttrs
      (map
        (user: rec {
          inherit (user) name;
          value = import (getHomeConfig path name);
        })
        users);
  in {
    home-manager.users = cfg;
  };
in {
  user = {
    inherit initUser mkNixOSUser mkNixOSUserModule mkNixOSHMModule mkHMUserModule getHomeConfig;
  };
}
