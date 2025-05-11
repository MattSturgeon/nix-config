{
  # 500GB Samsung 960 EVO:
  # - nvme-eui.0025385271b0477b
  # - nvme-Samsung_SSD_960_EVO_500GB_S3EUNX0J203327M
  # Contains / /nix and /persist
  # 4TB Crucial P3:
  # - nvme-CT4000P3SSD8_2232E65217B6
  # - nvme-nvme.c0a9-323233324536353231374236-435434303030503353534438-00000001
  # Contains /home
  # 2TB SATA Samsung 860 QVO:
  # - ata-Samsung_SSD_860_QVO_2TB_S4CYNF0M202257R
  # - wwn-0x5002538e40d17338
  # Not mounted, used for backups
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_500GB_S3EUNX0J203327M";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                # name is used in /dev/mapper/<name>
                # and in systemd-cryptsetup@<name>.service
                name = "main";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
      home = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT4000P3SSD8_2232E65217B6";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "home";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems = {
    "/persist".neededForBoot = true;
  };
}
