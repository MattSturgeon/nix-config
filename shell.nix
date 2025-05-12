# Shell for bootstrapping flake-enabled nix and home-manager
# You can enter it through 'nix develop' or (legacy) 'nix-shell'
{
  pkgs ? # If pkgs is not defined, instanciate nixpkgs from locked commit
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { overlays = [ ]; },
  ...
}:
pkgs.callPackage ./devshell {
  formatter = null;
}
