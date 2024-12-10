{ pkgs, ... }:
{
  config = {

    users.users.matt.extraGroups = [ "kvm" ];

    services.udev.packages = [
      pkgs.android-udev-rules
    ];
  };
}
