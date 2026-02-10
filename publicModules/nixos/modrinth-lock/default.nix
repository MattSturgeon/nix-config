/**
  This module extends nix-minecraft with a `servers.*.mods` option.

  The option allows managing server mods using a modrinth spec and accompanying
  modrinth lockfile.

  It assumes nix-minecraft is imported into the module eval.

  https://github.com/infinidoge/nix-minecraft
*/
{
  lib,
  pkgs,
  config,
  options,
  ...
}:
let
  cfg = config.services.minecraft-servers;
  opts = options.services.minecraft-servers;

  extraServerModule = lib.modules.importApply ./server.nix {
    inherit pkgs cfg opts;
  };

  modrinthLockType = lib.types.attrsOf (
    lib.types.submodule {
      options.sha512 = lib.mkOption {
        type = lib.types.str;
        description = "SHA-512 hash of the mod file";
      };
      options.url = lib.mkOption {
        type = lib.types.str;
        description = "Download URL for the mod";
      };
    }
    // {
      description = "Modrinth lockfile entry";
      descriptionClass = "noun";
      getSubOptions = _: { }; # Don't document sub-options
    }
  );
in
{
  options.services.minecraft-servers = {
    # Use option-declaration merging to extend nix-minecraft's `servers` submodule-type
    servers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule extraServerModule);
    };

    locks.modrinth = lib.mkOption {
      type = lib.types.coercedTo lib.types.path lib.importJSON modrinthLockType;
      default = { };
      description = ''
        Path to `modrinth.lock` JSON file, or an attrset of version metadata.

        The lockfile maps Modrinth version IDs to their download URLs and SHA-512 hashes.
      '';
    };
  };
}
