{
  inputs,
  outputs,
  ...
} @ attrs: let
  # TODO overlay util into nixpkgs.lib?
  util = outputs.lib;
  lib = inputs.nixpkgs.lib;
  inherit (builtins) filter pathExists dirOf readDir;
  inherit (lib) mapAttrsToList filterAttrs hasSuffix;
  inherit (lib.attrsets) mergeAttrsList; # no short form

  # Import each file, merging the result into a single attr set.
  # Note: assumes all files are functions that accept 'args' and return an attr set.
  mergedImport = files: args: mergeAttrsList (map (path: import path args) files);

  # Returns a list of nix files that are children of 'dir'
  # including 'default.nix' files found in child directories.
  nixChildren = dir: let
    # Maps a {name=type} attr back into a path
    # Adds '/default.nix' onto directory paths
    pathMapper = name: type:
      dir
      + ("/" + name)
      + (
        if type == "directory"
        then "/default.nix"
        else ""
      );

    # Filter out attrs that aren't directories or .nix files
    nixOrDirFilter = name: type:
      if type == "regular"
      then (hasSuffix ".nix" name)
      else type == "directory";

    # Each path is a '.nix' file or a 'subdir/default.nix'
    paths = mapAttrsToList pathMapper (filterAttrs nixOrDirFilter (readDir dir));
  in
    # Only return paths that actually exist
    filter pathExists paths;

  # Returns a list of nix files that are siblings of 'file',
  # including 'default.nix' files found in sibling directories.
  nixSiblings = file: filter (path: path != file) (nixChildren (dirOf file));

  args = attrs // {inherit util lib;};
in
  (mergedImport (nixSiblings ./default.nix) args)
  // {
    util = {
      inherit nixChildren nixSiblings mergedImport;
    };
  }
