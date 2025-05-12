let
  system = builtins.currentSystem or "unknown-system";
  flake = import ./.;
in
flake.devShells.${system}.default
