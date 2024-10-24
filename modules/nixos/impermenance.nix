{ config
, lib
, ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.custom.impermanence;
in
{
  options.custom.impermanence = {
    enable = mkEnableOption "impermenance";
    wipeOnBoot = mkEnableOption "wiping / on boot";
  };

  config = mkIf cfg.enable {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc" # Persist all of /etc because /etc/shadow can't be symlinked
        # "/etc/NetworkManager"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/flatpak"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "0755"; }
      ];
      files = [
        # "/etc/machine-id"
      ];
    };

    boot.initrd.systemd = mkIf cfg.wipeOnBoot {
      enable = true;
      services.reset-root = {
        description = "Backup & reset root subvolume";
        wantedBy = [
          "initrd.target"
        ];
        after = [
          # Require `main` be unlocked
          "systemd-cryptsetup@main.service"
        ];
        before = [
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          # Mount the LUKS volume
          mkdir -p /btrfs_tmp
          mount -o subvol=/ /dev/mapper/main /btrfs_tmp

          # Backup old roots
          if [[ -e /btrfs_tmp/root ]]; then
            mkdir -p /btrfs_tmp/old_roots
            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
          fi

          # Function to delete a subvolume
          delete_subvolume_recursively() {
            IFS=$'\n'
            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
            done
            btrfs subvolume delete "$1"
          }

          # Delete backups older than 30 days
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
            delete_subvolume_recursively "$i"
          done

          # Create a shiny new "root" subvolume
          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };
    };
  };
}
