{ util
, lib
, inputs
, outputs
, ...
}:
with builtins; let
  inherit (lib) nixosSystem;
  inherit (inputs.home-manager.lib) homeManagerConfiguration;
  inherit (util.util) nixChildren;

  # Platform to use when system is not provided
  defaultSystem = "x86_64-linux";

  # Include all inputs in specialArgs;
  # now we don't have to overlay stuff into nixpkgs
  specialArgs = inputs // { inherit inputs outputs util; };

  # Build a NixOS config, including Home Manager configs for any hmUsers specified
  mkSystemConfig =
    { hostname
    , system ? defaultSystem
    , nixosModules ? [ ]
    , homeManagerModules ? [ ]
    , ...
    }: nixosSystem {
      inherit system specialArgs;
      modules = nixosModules ++ [
        ../hosts/${hostname}/configuration.nix
        ../hosts/${hostname}/hardware-configuration.nix
        {
          # Configure hostname
          networking.hostName = hostname;

          # Pass modules to Home Manager
          home-manager.sharedModules = homeManagerModules;
        }
        inputs.home-manager.nixosModules.home-manager
      ];
    };

  # Builds a standalone Home Manager config, independent of NixOS
  mkHomeConfig =
    { hostname
    , username
    , home ? "/home/${username}"
    , system ? defaultSystem
    , modules ? [ ]
    , ...
    }: homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = specialArgs;
      modules = modules ++ [
        {
          # Pass in environment info
          custom.env.host = hostname;
          home.username = username;
          home.homeDirectory = home;
        }
        # TODO get config from ../home
        (getHomeConfig ../hosts/${hostname} username)
      ];
    };

  # Return the path to either 'home.nix' or '<username>.nix' in 'dir'.
  # If neither or both exist, the function will abort.
  # TODO refactor to use /users/name/home.nix
  #   or maybe have the user config specify path to home-manager config?
  getHomeConfig = dir: username:
    let
      count = length matches;
      chilren = nixChildren dir;
      matches = filter (file: elem (baseNameOf file) [ "home.nix" (username + ".nix") ]) chilren;
    in
    # Return the path to the (only) match.
    if count == 1 then head matches
    else if count > 1 # Abort if there isn't exactly one match.
    then abort "Multiple home files (${toString count}) found for ${username} in ${dir}"
    else abort "No valid home file found for ${username} in ${dir}";
in
{
  system = { inherit mkSystemConfig mkHomeConfig defaultSystem; };
}
