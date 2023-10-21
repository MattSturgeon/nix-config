{
  inputs,
  outputs,
  ...
} @ attrs: let
  # TODO overlay util into nixpkgs.lib?
  util = outputs.lib;
  lib = inputs.nixpkgs.lib;
  args = attrs // {inherit util lib;};
in
  (import ./util.nix args)
  // rec {
    # TODO include all functions in libs set
    # Maybe make a function which walks the filesystem

    # System creation functions
    system = import ./system.nix args;
    mkNixOSConfig = system.mkNixOSConfig;
    mkHMConfig = system.mkHMConfig;

    # User related functions
    user = import ./user.nix args;
  }
