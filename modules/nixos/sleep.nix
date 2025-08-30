{
  config = {
    services.logind.settings = {
      # Use suspend-then-hibernate when the lid is closed
      Login.HandleLidSwitch = "suspend-then-hibernate";
    };

    # When using sleep-then-hibernate,
    # sleep for 2h before hibernating
    systemd.sleep.extraConfig = "HibernateDelaySec=2h";

    # s2idle or deep may work better depending on hardware...
    # "deep" is traditional S3 sleep (suspend to RAM)
    # "s2idle" is a more modern low power sleep, aka S0ix.
    #     This _should_ use similar power but be faster.
    # s2idle currently isn't working on my Matebook
    boot.kernelParams = [ "mem_sleep_default=deep" ];
  };
}
