{ lib, config, ... }:
let
  inherit (config.networking) nftables;
in
{
  networking.firewall = {
    # For nftables configs
    extraInputRules = lib.mkIf nftables.enable ''
      # Accept all LAN traffic
      ip saddr 192.168.1.0/24 accept
    '';

    # For iptables configs
    extraCommands = lib.mkIf (!nftables.enable) ''
      # Accept all LAN traffic
      iptables --append INPUT --source 192.168.1.0/24 --jump ACCEPT
    '';
  };
}
