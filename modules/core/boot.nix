# Boot configuration: Bootloader, Kernel, Hibernation, Root-Wipe
{ pkgs, lib, ... }:

{
  # Bootloader (systemd-boot for UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  # Hardened Kernel
  boot.kernelPackages = pkgs.linuxPackages_hardened;

  # Faster boot: compress initrd with zstd (smaller = faster load)
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" ];

  # Hibernation: Resume from encrypted swap
  # LUKS unlock is handled by Disko automatically
  boot.resumeDevice = "/dev/pool/swap";

  # IMPERMANENCE: Root-Wipe Script
  # Deletes and recreates the root Btrfs subvolume on every boot
  # Note: On hibernate resume, the kernel restores RAM state before this runs
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount /dev/pool/root /btrfs_tmp || { echo "ERROR: Mount failed"; exit 1; }

    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    # Delete old roots older than 30 days
    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    # Create fresh root subvolume
    btrfs subvolume create /btrfs_tmp/root || { umount /btrfs_tmp; echo "ERROR: Subvolume creation failed"; exit 1; }
    umount /btrfs_tmp || echo "WARNING: Unmount failed"
  '';

  # Hardened kernel disables unprivileged user namespaces by default.
  # Chromium-based browsers (Chrome, Vivaldi) need them for sandboxing.
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

  # Enable btrfs support in initrd
  boot.supportedFilesystems = [ "btrfs" ];
}
