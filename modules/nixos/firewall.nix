{
  # firewalld uses either iptables or nftables as a backend, however its
  # iptables support deprecated.
  # It is possible that using nftables will cause issues, especially with
  # software that assumes it can use iptables, like docker.
  networking.nftables.enable = true;

  # Use firewalld for dynamic firewall zones that integrate well with networkmanager.
  services.firewalld.enable = true;
}
