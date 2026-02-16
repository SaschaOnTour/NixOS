# Disk configuration with LUKS, LVM, Btrfs and Swap for Hibernation
{ userConfig, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Device path from config.nix
        device = userConfig.disk;
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
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

            # LUKS encrypted partition
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ "--allow-discards" ];
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };

    # LVM Volume Group
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          # Swap partition for Hibernation (must be >= RAM size)
          swap = {
            # Swap size from config.nix
            size = userConfig.swapSize;
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          # Root filesystem with Btrfs subvolumes
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                # Root subvolume (gets wiped on boot)
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                # Nix store (persistent)
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };

                # Persistent data
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" "nodev" "nosuid" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
