{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.lm_sensors
  ];

  # Generated by sensors-detect on Thu Dec 12 13:01:44 2024
  boot.kernelModules = [
    "coretemp"
    "k10temp"
    "nct6775"
  ];
}
