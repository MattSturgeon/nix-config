{lib, ...}: let
  inherit (builtins) map listToAttrs toString length head attrNames filter readDir;
  inherit (lib) unique filterAttrs hasSuffix;
  # Private function to get a list of regular files whoes names end in .nix
  # Returns a list of filenames, not paths
  getNixFiles = path:
    attrNames (
      filterAttrs
      (k: v: v == "regular" && (hasSuffix ".nix" k))
      (readDir path)
    );

  adminGroups = ["wheel" "networkmanager"];
in rec {
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

  mkHMUserModule = user: let
    fUser = initUser user;
  in {
    home.username = fUser.name;
    home.homeDirectory = fUser.home;
  };

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

  # Just an overly complex mess that looks for _either_ home.nix or <username>.nix in the host path
  getHomeConfig = host: username: let
    count = length matches;
    matches =
      filter
      (f: f == "home.nix" || f == (username + ".nix"))
      (getNixFiles host);
  in
    # Return the path to the (only) match
    # Abort if there isn't exactly one match
    if count == 1
    then host + ("/" + (head matches))
    else if count > 1
    then abort "Multiple home files (${toString count}) found for ${username} in ${host}"
    else abort "No valid home file found for ${username} in ${host}";
}
