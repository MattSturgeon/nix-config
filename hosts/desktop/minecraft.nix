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
  inherit (self.packages.${system}) quad-modpack;

  minecraft-archive = self.packages.${system}.minecraft-archive.overrideAttrs {
    serversDir = config.services.minecraft-servers.dataDir;
  };
in
{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
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
        symlinks.mods = "${quad-modpack}/mods";
      };
    };
  };

  environment.systemPackages = [ minecraft-archive ];

  # Give matt read access to minecraft data
  users.users.matt.extraGroups = [ "minecraft" ];
}
