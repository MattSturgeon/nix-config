{
  lib,
  self,
  inputs,
  config,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.nix-minecraft.legacyPackages.${system}) minecraftServers;

  minecraft-archive = self.packages.${system}.minecraft-archive.overrideAttrs {
    serversDir = config.services.minecraft-servers.dataDir;
  };
in
{
  imports = [
    self.nixosModules.minecraft-modrinth-lock
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    locks.modrinth = ../../modrinth.lock;
    servers = {
      "quad" = {
        enable = true;
        package = minecraftServers.fabric-26_3.override (old: {
          jre_headless = lib.warnIf (
            lib.versions.major old.jre_headless.version == "25"
          ) "nix-minecraft is using Java 25, override is now redundant" pkgs.openjdk25_headless;
        });
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
        # Add/update version IDs here, then run: nix run .#update-modrinth-lock
        mods = {
          fabric-api.modrinth = "bNnaTiuM"; # 0.161.0+26.3
          lithium.modrinth = "WXHRsMRl"; # mc26.3-0.26.1-fabric
          ferrite-core.modrinth = "d5ddUdiB"; # 9.0.0-fabric
          simple-voice-chat.modrinth = "OLnMVWXy"; # 2.6.24+26.3
          shulker-box-tooltip.modrinth = "Cj9VEeGt"; # 5.4.2+26.3-fabric
          apple-skin.modrinth = "PHjDtQay"; # 3.0.10+mc26.3
        };
      };
    };
  };

  environment.systemPackages = [ minecraft-archive ];

  # Give matt read access to minecraft data
  users.users.matt.extraGroups = [ "minecraft" ];
}
