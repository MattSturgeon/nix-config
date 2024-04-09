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
            ({ pkgs, ... }: {
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
              boot.kernelParams = [ "copytoram" ];
              nix.settings.experimental-features = "nix-command flakes";
              environment.systemPackages = with pkgs; [
                disko
              ];
            })
          ];
          format = "gnome-installer-iso";
          customFormats.gnome-installer-iso = { modulesPath, ... }: {
            imports = [
              (modulesPath + "/installer/cd-dvd/installation-cd-graphical-gnome.nix")
            ];

            # Use a faster compression algorithm to speed up build times
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";

            formatAttr = "isoImage";
            fileExtension = ".iso";
          };
        };
      };
    };
}

