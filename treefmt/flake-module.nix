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
            command = lib.getExe pkgs.nixfmt;
            includes = [ "*.nix" ];
          };

          formatter.nixf-diagnose = {
            command = lib.getExe pkgs.nixf-diagnose;
            # Specific diagnostics can be ignored using `--ignore`
            # See https://github.com/nix-community/nixd/blob/main/libnixf/src/Basic/diagnostic.py
            options = [
              "--auto-fix"
              # Experimental primop `getFlake` false-positive unknown
              # https://github.com/nix-community/nixd/issues/762
              "--ignore=sema-primop-unknown"
            ];
            includes = [ "*.nix" ];
            # Make sure nixfmt cleans up after nixf-diagnose.
            priority = -1;
          };
        };
      };
    };
}
