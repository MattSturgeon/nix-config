{ config
, lib
, ...
}:
let
  inherit (lib) mkOption;
  cfg = config.custom.boot;
in
{
  options.custom.boot = {
    manager = mkOption {
      description = "The boot manager to use";
      default = "systemd-boot";
      type = lib.types.enum [ "systemd-boot" "grub" ];
    };
  };

  config = {
    boot.loader = {
      ${cfg.manager} = {
        enable = true;
      };

      # Disable boot timeout.
      # Spam "almost any key" to show the menu (<space> work well).
      # Or run: systemctl reboot --boot-loader-menu=0
      timeout = 0;

      efi.canTouchEfiVariables = true;
    };
  };
}
