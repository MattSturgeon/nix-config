{ self, inputs, ... }:
{
  flake = {
    # The nixvim module used to build `packages.<system>.nvim`
    nixvimModules.default = import ./config;
  };

  perSystem =
    {
      self',
      pkgs,
      system,
      ...
    }:
    let
      inherit (inputs.nixvim.legacyPackages.${system}) makeNixvimWithModule;
      inherit (inputs.nixvim.lib.${system}.check) mkTestDerivationFromNvim;
    in
    {
      # Run using `nix run .#nvim`
      packages.nvim = makeNixvimWithModule {
        inherit pkgs;
        module = self.nixvimModules.default;
        extraSpecialArgs = { inherit self inputs; };
      };

      # `nix flake check` will also validate config
      checks.nvim = mkTestDerivationFromNvim {
        inherit (self'.packages) nvim;
        name = "My custom neovim";
      };
    };
}
