{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (inputs.nix-minecraft.legacyPackages.${system}) minecraftServers;
in
{
  imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers = {
      "quad" = {
        enable = true;
        package = minecraftServers.fabric-1_21_11;
        jvmOpts = "-Xmx4G -Xms1G";
        serverProperties = {
          server-port = 43000;
          difficulty = 3;
          gamemode = 0;
          max-players = 5;
          motd = "Matt's Quad world";
          white-list = false;
        };
        # Add or update mods using their modrinth version id:
        # nix run .#modrinth-prefetch -- <version_id>
        symlinks.mods = pkgs.linkFarm "mods" {
          fabric-api = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/gB6TkYEJ/fabric-api-0.140.2%2B1.21.11.jar";
            sha512 = "af4465797d80401021a6aefc8c547200e7c0f8cae134299bf3fafbc310fa81f055246b0614fc0e037538f4a844e55aad30abfa3c67460422853dfc426f086d00";
          };
          lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/4DdLmtyz/lithium-fabric-0.21.1%2Bmc1.21.11.jar";
            sha512 = "0857d30d063dc704a264b2fe774a7e641926193cfdcde72fe2cd603043d8548045b955e30c05b1b2b96ef7d1c0f85d55269da26f44a0644c984b45623e976794";
          };
          ferrite-core = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/eRLwt73x/ferritecore-8.0.3-fabric.jar";
            sha512 = "be600543e499b59286f9409f46497570adc51939ae63eaa12ac29e6778da27d8c7c6cd0b3340d8bcca1cc99ce61779b1a8f52b990f9e4e9a93aa9c6482905231";
          };
          simple-voice-chat = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/T42QJY4i/voicechat-fabric-1.21.11-2.6.10.jar";
            sha512 = "5da377423b2e48cf6729eab3f67eb82b21d591dee8ff060b2f9295c2743994ca3b49abe77c4b8d2480286c7e6e71f2f19afaf45e13d3794685b726cf2431fc19";
          };
          shulker-box-tooltip = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/2M01OLQq/versions/8Z4OG11C/shulkerboxtooltip-fabric-5.2.14%2B1.21.11.jar";
            sha512 = "55490c21c98a6c5bd704674a7435a7df2853e9e7ab8872b2a62264444110ad11eac23133e0c1e36ff484531bf849d5fa4a71eb0bf32a9b9c4f3afe33779d1c71";
          };
          apple-skin = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/EsAfCjCV/versions/pvcLnrm0/appleskin-fabric-mc1.21.11-3.0.7.jar";
            sha512 = "dfc990170b969f3213a9912d13c3fc0d067e2e88faf1a6c7a69bd1a463cd6144ac2dcaeb6a2a3150b595378c1f9449fb0740714ff7703c18c93f8ae3c9eceaa3";
          };
        };
      };
    };
  };
}
