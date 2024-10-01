{
  # lsp-lines, but only for the current line
  plugins.lsp-lines.enable = true;
  diagnostics.virtual_lines.only_current_line = true;

  plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      jdt-language-server.enable = true; # Java LSP from Eclipse
      lua-ls.enable = true;
      ruff-lsp.enable = true; # Python linter
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
        settings = {
          # TODO: we can define these if this flake is installed to
          # a consistent location.
          #
          # nixpkgs.expr = null;
          # options = {
          #   flake-parts.expr = null;
          #   home-manager.expr = null;
          #   nixvim.expr = null;
          # };
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
      ts-ls.enable = true; # TypeScript & JavaScript
      zls.enable = true; # Zig
      rust-analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };
}
