# Security configuration: Persistence, AppArmor, Firewall
{ pkgs, userConfig, ... }:

{
  # Persist partition must be available early
  fileSystems."/persist".neededForBoot = true;

  # IMPERMANENCE: Define what survives reboots
  environment.persistence."/persist" = {
    hideMounts = true;

    # System-level directories
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/docker"
      "/var/lib/bluetooth"
      "/var/lib/systemd/coredump"
      "/var/lib/flatpak"
      "/var/lib/plocate"
      "/etc/NetworkManager/system-connections"
    ];

    # System-level files
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    # User-level persistence
    users.${userConfig.username} = {
      directories = [
        # Standard folders
        "Downloads"
        "Documents"
        "Pictures"
        "Music"
        "Videos"
        "Projects"
        "GoogleDrive"

        # SSH & Git
        ".ssh"
        # Browser profiles
        ".mozilla"
        ".config/vivaldi"
        ".config/google-chrome"

        # Application configs
        ".thunderbird"
        ".config/keepassxc"
        ".config/rclone"
        ".config/niri"
        ".config/zed"
        ".local/share/zed"
        ".config/obs-studio"
        ".config/vlc"
        ".config/localsend"

        # AI tools
        ".claude"
        ".codex"
        ".config/opencode"
        ".config/claude-code"
        ".local/share/claude-code"
        ".npm"

        # JetBrains IDEs (Rider, RustRover, IntelliJ)
        ".config/JetBrains"
        ".local/share/JetBrains"
        ".java/.userPrefs"

        # Development caches
        ".cache/cargo-target"
        ".cargo"
        ".m2"
        ".nuget"

        # Shell history
        ".local/share/fish"

        # Flatpak
        ".local/share/flatpak"
        ".var/app"
      ];
    };
  };

  # AppArmor
  security.apparmor.enable = true;

  # Firewall
  networking.firewall.enable = true;

  # Sudo configuration
  security.sudo.wheelNeedsPassword = true;

  # PAM for swaylock (required for lock screen to accept password)
  security.pam.services.swaylock = {};
}
