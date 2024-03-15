{ util
, inputs
, ...
}:
with builtins;
let
  inherit (util.util) importAll nixChildren;
in
{
  util = {
    /*
      Generates an attribute set by mapping a function over each system supproted.

      Example:
      forAllSystems (system: pkgs: "Uses " + system)
      => { x86_64-linux = "Uses x86_64-linux"; aarch64-darwin = "Uses aarch64-darwin"; ... }

      Type:
      forAllSystems :: (String -> AttrSet -> Any) -> AttrSet
    */
    forAllSystems = f: mapAttrs f inputs.nixpkgs.legacyPackages;

    # Import all children of the directory, including default.nix files in child directories.
    # Note: not actually recursive; grandchildren (etc) are not imported.
    importChildren = dir: importAll (nixChildren dir);
  };
}
