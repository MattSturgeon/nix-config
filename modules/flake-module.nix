{ self, ... }:
let
  inherit (self.lib.util) importChildren;
in
{
  flake = {
    nixosModules = {
      common = {
        imports = importChildren ../modules/common;
      };
      nixos = {
        imports = importChildren ../modules/nixos;
      };
    };

    homeModules = {
      common = {
        imports = importChildren ../modules/common;
      };
      home = {
        imports = importChildren ../modules/home-manager;
      };
    };
  };
}
