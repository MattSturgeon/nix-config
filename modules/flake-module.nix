{
  imports = [ ./legacy.nix ]; # FIXME remove

  flake = {
    nixosModules.default = ./nixos;
    homeModules.default = ./home;
    homeModules.nonNixOS = ./nonNixOSHome;
  };
}
