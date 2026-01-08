{ pkgs, ... }:
{
  config = {
    users.users.matt.extraGroups = [ "kvm" ];
    environment.systemPackages = [
      pkgs.android-tools
    ];
  };
}
