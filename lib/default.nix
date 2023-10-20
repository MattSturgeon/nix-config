{
  inputs,
  outputs,
  ...
}: let
  # TODO overlay util into nixpkgs.lib?
  util = outputs.lib;
  lib = inputs.nixpkgs.lib;
in rec {
  # TODO include all functions in libs set
  # Maybe make a function which walks the filesystem
  example = a: b: a;
  # example2 is an alias for nixpkgs.lib.count:
  example2 = lib.count;

  # System creation functions
  system = import ./system.nix {inherit util lib inputs outputs;};
  mkNixOSConfig = system.mkNixOSConfig;
  mkHMConfig = system.mkHMConfig;

  # User related functions
  user = import ./user.nix {inherit util lib inputs outputs;};
}
