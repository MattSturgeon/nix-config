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

          # Use the beta nixpkgs-fmt
          # Alejandra is too strict...
          formatter.nixpkgs-fmt = {
            command = lib.getExe pkgs.nixpkgs-fmt;
            includes = [ "*.nix" ];
          };
        };
      };
    };
}
