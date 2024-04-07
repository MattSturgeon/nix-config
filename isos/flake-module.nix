{ self, inputs, ... }:
let
  inherit (inputs.nixos-generators) nixosGenerate;
  specialArgs = { inherit self inputs; };
in
{
  perSystem =
    { system, ... }: {
      packages = {
        installer = nixosGenerate {
          inherit system specialArgs;
          modules = [
            self.nixosModules.common
            inputs.home-manager.nixosModules.home-manager
            {
              # TODO move to a separate configuration file
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = specialArgs;
                sharedModules = [ self.homeModules.home ];
                users.nixos = {
                  # TODO home config
                  home.stateVersion = "23.11";
                };
              };
            }
          ];
          format = "gnome-installer-iso";
          customFormats.gnome-installer-iso = { modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
            ];

            formatAttr = "isoImage";
            fileExtension = ".iso";
          };
        };
      };
    };
}

