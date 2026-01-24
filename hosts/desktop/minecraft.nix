{
  self,
  inputs,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.nix-minecraft.legacyPackages.${system}) minecraftServers;
in
{
  imports = [
    self.nixosModules.minecraft-modrinth-lock
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  config.services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    locks.modrinth = ../../modrinth.lock;
    servers = {
      "quad" = {
        enable = true;
        package = minecraftServers.fabric-1_21_11;
        jvmOpts = "-Xmx4G -Xms1G";
        serverProperties = {
          motd = "Matt's Quad world";
          level-seed = "-3431479793612438569";
          difficulty = "hard";
          gamemode = "survival";
          view-distance = 20;
          simulation-distance = 10;
          max-players = 5;
          white-list = false;
          server-port = 43000;
        };

        # Modrinth mods defined by their version IDs.
        # To update, lookup the version ID of the mod file and edit `modrinth.lock`.
        mods = {
          fabric-api.modrinth = "gB6TkYEJ";
          lithium.modrinth = "4DdLmtyz";
          ferrite-core.modrinth = "eRLwt73x";
          simple-voice-chat.modrinth = "T42QJY4i";
          shulker-box-tooltip.modrinth = "8Z4OG11C";
          apple-skin.modrinth = "pvcLnrm0";
        };
      };
    };
  };
}
