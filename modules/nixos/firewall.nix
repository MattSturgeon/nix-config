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
      iptables --append nixos-fw \
        --protocol tcp \
        --source 192.168.1.0/24 \
        --jump nixos-fw-accept
      iptables --append nixos-fw \
        --protocol udp \
        --source 192.168.1.0/24 \
        --jump nixos-fw-accept
    '';
    extraStopCommands = lib.mkIf (!nftables.enable) ''
      # Accept all LAN traffic
      iptables --delete nixos-fw \
        --protocol tcp \
        --source 192.168.1.0/24 \
        --jump nixos-fw-accept ||
        true
      iptables --delete nixos-fw \
        --protocol udp \
        --source 192.168.1.0/24 \
        --jump nixos-fw-accept ||
        true
    '';
  };
}
