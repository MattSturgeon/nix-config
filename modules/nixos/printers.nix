{
  # Enable CUPS
  services.printing.enable = true;

  # Enable zeroconf DNS discovery to automatically find printers
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
