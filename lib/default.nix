{
  self,
  inputs,
  ...
}@attrs:
let
  lib = inputs.nixpkgs.lib;
  inherit (builtins)
    filter
    pathExists
    dirOf
    readDir
    ;
  inherit (lib)
    mapAttrsToList
    filterAttrs
    hasSuffix
    foldr
    recursiveUpdate
    ;

  # Map a list of paths to a list of (imported) nix expressions
  importAll = list: map import list;

  # Returns a list of nix files that are children of 'dir'
  # including 'default.nix' files found in child directories.
  nixChildren =
    dir:
    let
      # Maps a file or directory -> module path
      toModule = name: type: dir + (if type == "directory" then "/${name}/default.nix" else "/${name}");

      # Filter directories and .nix files
      moduleFilter =
        name: type: if type == "regular" then (hasSuffix ".nix" name) else type == "directory";

      # A list of child modules
      children = mapAttrsToList toModule (filterAttrs moduleFilter (readDir dir));
    in
    # Only return paths that actually exist
    if pathExists dir then filter pathExists children else [ ];

  # Returns a list of nix files that are siblings of 'file',
  # including 'default.nix' files found in sibling directories.
  nixSiblings = file: filter (path: path != file) (nixChildren (dirOf file));

  # As per mergeAttrsList, but merge sets recursively
  recursiveMergeAttrsList = foldr (l: r: recursiveUpdate l r) { };

  # Arguments to pass to each imported sibling
  args = {
    inherit lib;
    util = self.lib;
  }
  // attrs;
in
# Merge everything in lib/, including functions defined above
recursiveMergeAttrsList (
  [
    {
      util = {
        inherit
          nixChildren
          nixSiblings
          importAll
          recursiveMergeAttrsList
          ;
      };
    }
  ]
  ++ (map (f: f args) (importAll (nixSiblings ./default.nix)))
)
