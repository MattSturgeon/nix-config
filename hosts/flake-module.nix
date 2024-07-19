{ self, inputs, lib, ... }:
let
  specialArgs = { inherit self inputs; };

  guessUsername = name:
    let
      parts = lib.splitString "@" name;
      len = builtins.length parts;
    in
    if len == 2 then builtins.head parts else name;

  guessHostname = name:
    let
      parts = lib.splitString "@" name;
      len = builtins.length parts;
    in
    lib.optionalString (len == 2) (builtins.elemAt parts 1);

  mkSystem = name:
    { system
    , username ? "matt"
    , fullname ? "Matt Sturgeon"
    , modules ? [ ]
    , ...
    }: inputs.nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = modules ++ [
        ./${name}/configuration.nix
        self.nixosModules.common
        self.nixosModules.nixos
        inputs.disko.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        {
          networking.hostName = lib.mkDefault name;
          users.users.${username} = {
            description = fullname;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "init";
            isNormalUser = true;
          };
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            sharedModules = [ self.homeModules.home ];
            users.${username} = ./${name}/home.nix;
          };
        }
      ];
    };

  mkHome = name:
    { system
    , username ? guessUsername name
    , hostname ? guessHostname name
    , modules ? [ ]
    , ...
    }: inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = specialArgs;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = modules ++ [
        # FIXME doesn't support username-specific configs
        ./${hostname}/home.nix
        self.homeModules.common
        self.homeModules.home
        {
          home.username = username;
          home.homeDirectory = "/home/${username}";
        }
      ];
    };
in
{
  flake = {
    # NixOS configurations
    nixosConfigurations = builtins.mapAttrs mkSystem {
      matebook = { system = "x86_64-linux"; };
      desktop = { system = "x86_64-linux"; };
    };

    # Standalone home-manager configurations
    homeConfigurations = builtins.mapAttrs mkHome { };
  };
}
