{ self, ... }:
{
  # lsp-lines, but only for the current line
  plugins.lsp-lines.enable = true;
  diagnostics.virtual_lines.only_current_line = true;

  plugins.lsp = {
    enable = true;

    servers = {
      bashls.enable = true;
      jdtls.enable = true; # Java LSP from Eclipse
      lua_ls.enable = true;
      ruff_lsp.enable = true; # Python linter
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
        settings =
        let
            flake = ''(builtins.getFlake "${self}")'';
            system = ''''${builtins.currentSystem}'';
        in
        {
          nixpkgs.expr = "import ${flake}.inputs.nixpkgs { }";
          options = rec {
            nixos.expr = "${flake}.nixosConfigurations.desktop.options";
            home-manager.expr = "${nixos.expr}.home-manager.users.type.getSubOptions [ ]";
            nixvim.expr = "${flake}.packages.${system}.nvim.options";
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
      rust_analyzer = {
        enable = true;
        installCargo = true;
        installRustc = true;
      };
    };
  };
}
