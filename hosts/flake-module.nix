{ self, ... }:
let
  inherit (self.lib) mkNixOSConfig mkHMConfig;

  # Define my user, used by most configurations
  # see initUser in lib/user.nix
  userMatt = {
    name = "matt";
    description = "Matt Sturgeon";
    initialPassword = "init";
    isAdmin = true;
  };
in
{
  flake = {
    # NixOS configurations
    nixosConfigurations = {
      matebook = mkNixOSConfig {
        hostname = "matebook";
        hmUsers = [ userMatt ];
        nixosModules = with self.nixosModules; [ common nixos ];
        homeManagerModules = [ self.homeModules.home ];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      "matt@desktop" = mkHMConfig {
        hostname = "desktop";
        user = userMatt;
        modules = with self.homeModules; [ common home ];
      };
    };
  };
}
