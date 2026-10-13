{ self, pkgs, ... }:
{
  # nvim-lspconfig has sane defaults for many LSP servers
  plugins.lspconfig.enable = true;

  lsp = {
    inlayHints.enable = true;

    servers = {
      bashls.enable = true;
      jdtls.enable = true; # Java LSP from Eclipse
      lua_ls.enable = true;
      ruff.enable = true; # Python linter
      ty.enable = true; # Python type-checker
      nixd = {
        # Nix LS
        enable = true;
        config.settings =
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
      ccls.enable = true; # C/C++/ObjC LS
      #cangd.enable = true; # LLVM C/C++ LS
      gopls.enable = true; # Golang LS
      ts_ls.enable = true; # TypeScript & JavaScript
      zls.enable = true; # Zig
      rust_analyzer.enable = true;
    };
  };

  extraPackagesAfter = [
    # Needed by rust_analyzer
    # TODO: use upstream rust_analyzer.cargo.enable options:
    # https://github.com/nix-community/nixvim/pull/4571
    pkgs.cargo
    pkgs.rustc

    # Needed by hls
    # TODO: migrate legacy hls.installGhc option upstream
    pkgs.ghc
  ];
}
