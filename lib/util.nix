{ lib
, util
, ...
}:
let
  inherit (lib) genAttrs;
  inherit (util.util) importAll nixChildren;
in
{
  util = {
    /*
      Generates an attribute set by mapping a function over each system listed.

      Example:
      forAllSystems (system: "Uses " + system)
      => { x86_64-linux = "Uses x86_64-linux"; aarch64-darwin = "Uses aarch64-darwin"; ... }

      Type:
      forAllSystems :: (String -> Any) -> AttrSet
    */
    forAllSystems = genAttrs [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    # Import all children of the directory, including default.nix files in child directories.
    # Note: not actually recursive; grandchildren (etc) are not imported.
    importChildren = dir: importAll (nixChildren dir);
  };
}
