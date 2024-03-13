{ lib, ... }:
with lib; {
  modules = {
    /*
      Like `mkBefore`, but higher priority.
    */
    mkFirst = mkOrder 200;

    /*
      Like `mkAfter`, but lower priority.
    */
    mkLast = mkOrder 2000;

    /*
      Wrap `mkIf`, predicated on the value not being null.
    */
    nullableMkIf = attrs: mkIf (attrs != null) attrs;
  };
}
