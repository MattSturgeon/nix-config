{ lib
, util
, ...
}:
with builtins;
with lib;
let

  /*
     Import a nix file, invoking it if it is a function.

     (Private helper function)
  */
  importNix = file:
    let
      imported = import file;
      resolved =
        if isFunction imported
        then imported { inherit users lib util; }
        else imported;
    in
    resolved;

  /*
     Returns the provided value, panicking if it is not an AttrSet.

     (Private helper function)
  */
  assertAttrs = attrs: assert isAttrs attrs; attrs;

  /*
     A set of all users defined in `/users`

     User files can be JSON, TOML, AttrSet, or function (AttrSet -> AttrSet).

     If a nix function, it will be called with the following attributes:
     - users: the final users set (recursive)
     - lib: nixpkgs.lib
     - util: this library
  */
  users =
    let
      root = ../users;

      # Attrs mapping function:
      # filename -> filetype -> {username=user}
      toUserPair = filename: filetype:
        let
          # Split filename by '.' so we can get the file extension
          parts = splitString "." filename;
          len = length parts;

          # ext and type represent the file extension
          ext = elemAt parts (len - 1);
          type = toLower ext;

          # The username without the file extension
          username = concatStringsSep "." (sublist 0 (len - 1) parts);

          # The actual file to be loaded
          file = root + "/${filename}";

          /*
             A function that can load a user file, or null.

             `null` when the file cannot be loaded;
             otherwise one of `importNix`, `importTOML`, `importJSON`
          */
          load =
            # Can't load directories
            if filetype == "directory" then warn "ignoring directory in `users`"
            # Can't load files without an extension:
            else if len < 2 then warn "ignoring file in `users` with no extension"
            # Actually supported file types:
            else if type == "nix" then importNix
            else if type == "toml" then importTOML
            else if type == "json" then importJSON
            # Can't load unknown file types
            else warn "ignoring file in `users` with unknown type (${type})";

          # Helper to ignore with a warning
          # Prints a warning then returns `null`.
          warn = msg: trace ''WARNING: ${msg}: "${filename}"'' null;
        in
        # Only evaluate user if `load` is non-null
        if load == null then { }
        # Panic if the file doesn't load as an AttrSet
        else { ${username} = assertAttrs (load file); };
    in
    concatMapAttrs toUserPair (readDir root);
in
{ inherit users; } # users is the only public export
