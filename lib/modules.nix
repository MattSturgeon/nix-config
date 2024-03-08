{ lib, ... }:
let
  inherit (lib) mkOrder;
in
{
  modules = {
    /*
      Like `mkBefore`, but higher priority.
    */
    mkFirst = mkOrder 200;

    /*
      Like `mkAfter`, but lower priority.
    */
    mkLast = mkOrder 2000;
  };
}
