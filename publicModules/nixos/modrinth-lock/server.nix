{
  pkgs,
  cfg,
  opts,
}:
{
  lib,
  config,
  options,
  ...
}:
let
  taggedMod = lib.types.attrTag {
    modrinth = lib.mkOption {
      type = lib.types.str;
      description = "Modrinth version ID.";
    };
  };

  coerceTagged = {
    __functor =
      self: def:
      let
        # types.attrTag ensures one attr per definition (the tag)
        tag = builtins.head (builtins.attrNames def);
      in
      self.${tag} def.${tag};

    modrinth =
      versionId:
      let
        lock =
          cfg.locks.modrinth.${versionId} or (
            let
              locations = lib.concatMapStrings (file: "\n  - ${toString file}") opts.locks.modrinth.files;
            in
            throw "Modrinth mod version '${versionId}' not found in `${opts.locks.modrinth}` (try re-generating your lockfile). Defined in:${locations}"
          );
      in
      pkgs.fetchurl {
        inherit (lock) url sha512;
        passthru = {
          modrinth = true;
          inherit versionId;
        };
      };
  };

  modType = lib.types.coercedTo taggedMod coerceTagged lib.types.path;
in
assert
  (builtins.attrNames taggedMod.nestedTypes)
  == (builtins.attrNames (removeAttrs coerceTagged [ "__functor" ]));
{
  options.mods = lib.mkOption {
    type = lib.types.attrsOf modType;
    default = { };
    description = "Modrinth mods to install on this server.";
  };
  config.symlinks = lib.mkIf (config.mods != { }) {
    mods = lib.mkDerivedConfig options.mods (
      mods:
      pkgs.linkFarm "server-mods" (
        lib.mapAttrs' (name: value: {
          name = name + ".jar";
          inherit value;
        }) mods
      )
    );
  };
}
