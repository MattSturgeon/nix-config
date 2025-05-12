{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.callPackage ./. {
        inherit (config) formatter;
      };
    };
}
