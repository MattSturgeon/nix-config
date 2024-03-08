{ config
, lib
, ...
}:
let
  inherit (builtins) length head;
  inherit (lib) mkIf;
  inherit (config) swapDevices;

  supported = (length swapDevices) > 0;
in
{
  config = mkIf supported {
    # Use suspend-then-hibernate when the lid is closed
    services.logind.lidSwitch = "suspend-then-hibernate";

    # When using sleep-then-hibernate,
    # sleep for 2h before hibernating
    systemd.sleep.extraConfig = "HibernateDelaySec=2h";

    # s2idle or deep may work better depending on hardware...
    # "deep" is traditional S3 sleep (suspend to RAM)
    # "s2idle" is a more modern low power sleep, aka S0ix.
    #     This _should_ use similar power but be faster.
    boot.kernelParams = [ "mem_sleep_default=s2idle" ];

    # FIXME this shouldn't be needed...
    # resumeDevice should default to the first swapDevice anyway
    boot.resumeDevice = (head swapDevices).device;
  };
}
