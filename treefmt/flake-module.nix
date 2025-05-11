{ lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.treefmt.withConfig {
        settings = {
          # TODO: drop once treefmt defaults to `git rev-parse --show-toplevel`
          # See https://github.com/numtide/treefmt/pull/571
          tree-root-file = "flake.lock";

          # Configure nixfmt for .nix files
          formatter.nixfmt = {
            command = lib.getExe pkgs.nixfmt-rfc-style;
            includes = [ "*.nix" ];
          };
        };
      };
    };
}
