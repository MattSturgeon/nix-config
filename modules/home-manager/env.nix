{ config
, lib
, util
, ...
} @ attrs:
let
  username = config.home.username;

  userOptions = {
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
  };

  /*
     Remove unsupported attributes from a user
  */
  supported = lib.filterAttrs (name: _: userOptions ? ${name});

  # Detect the environment from home-manager's specialArgs
  env = {
    standalone = !(attrs ? osConfig);
    nixos = attrs ? nixosConfig;
    darwin = attrs ? darwinConfig;
  };

  cfg = config.custom;
in
{

  options.custom = {
    user = userOptions;
    env = {
      host = lib.mkOption {
        type = lib.types.str;
        description = "The system hostname";
      };
      standalone = lib.mkOption {
        type = lib.types.bool;
        description = "Whether this is a standalone home-manager config";
      };
      nixos = lib.mkOption {
        type = lib.types.bool;
        description = "Whether home-manager is configured via the NixOS module";
      };
      darwin = lib.mkOption {
        type = lib.types.bool;
        description = "Whether home-manager is configured via the nix-darwin module";
      };
      foreign = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the configuration is targeting an foreign host";
      };
    };
  };

  config.assertions =
    with builtins;
    with cfg.env;
    let
      vals = { inherit standalone nixos darwin; };
      set = attrNames (lib.filterAttrs (name: val: val) vals);
      count = length set;
      fmt = strs: concatStringsSep ", " (map (str: "`custom.env.${str}`") (lib.toList strs));
    in
    [
      {
        assertion = foreign -> standalone;
        message = "${fmt "foreign"} was set without ${fmt "standalone"}.";
      }
      {
        assertion = count > 0;
        message = "None of ${fmt (attrNames vals)} were set.";
      }
      {
        assertion = count < 2;
        message = "Incompatible values were set: ${fmt set}.";
      }
    ];

  config.custom = lib.mkMerge [
    {
      # Apply detected environment
      inherit env;

      # Load user info
      user = lib.mkDefault (supported util.users.${username});
    }
    # Note: use `optionalAttrs` instead of `mkIf` to avoid the module system attempting
    # to validate (and panicking) when `osConfig` doesn't exist...
    (lib.optionalAttrs (env.nixos || env.darwin) {
      # Get system hostname
      env.host = lib.mkForce attrs.osConfig.networking.hostName;

      # Override loaded user info with OS config's
      user = lib.mkForce (supported attrs.osConfig.custom.users.${username});
    })
  ];
}
