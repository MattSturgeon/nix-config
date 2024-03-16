{ lib
, config
, util
, ...
}:
let
  inherit (util.modules) nullableMkIf;

  userOption = {
    options = {
      enable = lib.mkEnableOption "user";
      uid = lib.mkOption {
        type = with lib.types; nullOr int;
        default = null;
        description = "The user's UID";
      };
      description = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The user's full name";
      };
      email = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "The user's email address";
      };
      home = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''The user's home directory. If null, "/home/<<username>>" is used.'';
      };
      shell = lib.mkOption {
        type = with lib.types; nullOr (either str shellPackage);
        default = null;
        description = "The user's login shell";
      };
      admin = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the user should be added to the wheel group";
      };
      groups = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "Groups to add the user to";
      };
      initialPassword = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = "initial password (or null)";
      };
    };
  };

  # Wrap util's `getHomeConfig`, using the system hostname
  getHomeConfig = util.system.getHomeConfig config.networking.hostName;

  # Enabled users
  users = lib.filterAttrs (_: user: user.enable) config.custom.users;
in
{

  options.custom.users = lib.mkOption {
    description = "A set of users.";
    type = with lib.types; attrsOf (submodule userOption);
    default = { };
  };

  config = {
    # Load user definitions
    custom.users = lib.mapAttrs (name: user: { home-manager-config = lib.mkDefault (getHomeConfig name); } // user) util.users;

    # Map user definitions to NixOS user configs
    users.users = builtins.mapAttrs
      (name: user: {
        inherit (user) uid description initialPassword;
        isNormalUser = true;
        useDefaultShell = user.shell == null;
        shell = nullableMkIf user.shell;
        home = nullableMkIf user.home;
        extraGroups = user.groups ++ lib.optional user.admin "wheel";
      })
      users;
  };
}
