{
  self,
  inputs,
  lib,
  ...
}:
let
  specialArgs = { inherit self inputs; };

  guessUsername =
    name:
    let
      parts = lib.splitString "@" name;
      len = builtins.length parts;
    in
    if len == 2 then builtins.head parts else name;

  guessHostname =
    name:
    let
      parts = lib.splitString "@" name;
      len = builtins.length parts;
    in
    lib.optionalString (len == 2) (builtins.elemAt parts 1);

  mkSystem =
    name:
    {
      username ? "matt",
      fullname ? "Matt Sturgeon",
      modules ? [ ],
      ...
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
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
            extraGroups = [
              "wheel"
              "networkmanager"
            ];
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

  mkHome =
    name:
    {
      system ? null,
      username ? guessUsername name,
      hostname ? guessHostname name,
      modules ? [ ],
      ...
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = specialArgs;
      modules =
        modules
        ++ [
          # FIXME doesn't support username-specific configs
          ./${hostname}/home.nix
          self.homeModules.common
          self.homeModules.home
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
        ]
        ++ lib.optional (system != null) {
          nixpkgs.hostPlatform = system;
        };
    };

  # Groups a set of configurations by their `pkgs` arg's `system`,
  # applying a `mapAttrs'`-style mapping function to each configuration.
  mapConfigurationsBySystem' =
    fn: set:
    let
      getSystem = name: set.${name}._module.args.pkgs.stdenv.hostPlatform.system;
      namesToAttrs =
        names:
        lib.pipe names [
          (map (name: fn name set.${name}))
          builtins.listToAttrs
        ];
    in
    lib.pipe set [
      builtins.attrNames
      (builtins.groupBy getSystem)
      (builtins.mapAttrs (_: namesToAttrs))
    ];
in
{
  imports = [
    inputs.home-manager.flakeModules.home-manager
  ];

  flake = {
    # NixOS configurations
    nixosConfigurations = builtins.mapAttrs mkSystem {
      matebook = { };
      desktop = { };
    };

    # Standalone home-manager configurations
    homeConfigurations = builtins.mapAttrs mkHome { };

    # Propagate the configuration outputs to the flake's `checks`
    # This allows checking they all build by running `nix flake check`
    checks = lib.mkMerge [
      # NixOS
      (mapConfigurationsBySystem' (name: configuration: {
        name = "nixos-${name}";
        value = configuration.config.system.build.toplevel;
      }) self.nixosConfigurations)
      # home-manager
      (mapConfigurationsBySystem' (name: configuration: {
        name = "hm-${name}";
        value = configuration.config.home.activationPackage;
      }) self.homeConfigurations)
    ];
  };
}
