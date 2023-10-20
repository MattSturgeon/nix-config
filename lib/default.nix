{inputs, ...}: let
  lib = inputs.nixpkgs.lib;
in {
  # TODO include all functions in libs set
  # Maybe make a function which walks the filesystem
  example = a: b: a;
  # example2 is an alias for nixpkgs.lib.count:
  example2 = lib.count;
}
