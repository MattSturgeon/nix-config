{
  lib,
  self,
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  plugins.lsp = {
    enable = true;
    inlayHints = true;

    servers = {
      bashls.enable = true;
      jdtls.enable = true; # Java LSP from Eclipse
      lua_ls.enable = true;
      ruff.enable = true; # Python linter
      # Python type-checker
      pyright = {
        enable = true;
        settings = {
          # Disable ruff conflicts:
          pyright.disableOrganizeImports = true;
          python.analysis.ignore = [ "*" ];
        };
      };
      nixd = {
        # Nix LS
        enable = true;
        package =
          lib.warnIf (lib.versionAtLeast pkgs.nixd.version "2.6.4")
            "nvim lsp: unecessary package override for nixd"
            inputs.nixd.packages.${system}.default;
        settings =
          let
            # The wrapper curries `_nixd-expr.nix` with the `self` and `system` args
            # This makes `init.lua` a bit DRYer and more readable
            wrapper = builtins.toFile "expr.nix" ''
              import ${./_nixd-expr.nix} {
                self = ${builtins.toJSON self};
                system = ${builtins.toJSON pkgs.stdenv.hostPlatform.system};
              }
            '';
            # withFlakes brings `local` and `global` flakes into scope, then applies `expr`
            withFlakes = expr: "with import ${wrapper}; " + expr;
          in
          {
            nixpkgs.expr = withFlakes ''
              import (if local ? lib.version then local else local.inputs.nixpkgs or global.inputs.nixpkgs) { }
            '';
            options = rec {
              flake-parts.expr = withFlakes "local.debug.options or global.debug.options";
              nixos.expr = withFlakes "global.nixosConfigurations.desktop.options";
              home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions [ ]";
              nixvim.expr = withFlakes "global.nixvimConfigurations.\${system}.default.options";
            };
            diagnostic = {
              # Suppress noisy warnings
              suppress = [
                "sema-escaping-with"
                "var-bind-to-this"
              ];
            };
          };
      };
      hls.enable = true; # Haskell LS
      hls.installGhc = true;
      ccls.enable = true; # C/C++/ObjC LS
      #cangd.enable = true; # LLVM C/C++ LS
      gopls.enable = true; # Golang LS
      ts_ls.enable = true; # TypeScript & JavaScript
      zls.enable = true; # Zig
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };
}
