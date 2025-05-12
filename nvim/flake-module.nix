{
  lib,
  self,
  inputs,
  ...
}:
{
  imports = [
    inputs.nixvim.flakeModules.default
  ];

  nixvim =
    let
      nameFunction = name: "nvim" + lib.optionalString (name != "default") "-${name}";
    in
    {
      # Run using `nix run .#nvim`
      packages = {
        enable = true;
        inherit nameFunction;
      };

      # Test nixvim configurations in `nix flake check`
      checks = {
        enable = true;
        inherit nameFunction;
      };
    };

  flake.nixvimModules = {
    default = ./config;
  };

  perSystem =
    { system, ... }:
    {
      nixvimConfigurations = {
        default = inputs.nixvim.lib.evalNixvim {
          inherit system;
          extraSpecialArgs = { inherit self inputs; };
          modules = [
            self.nixvimModules.default
          ];
        };
      };
    };
}
