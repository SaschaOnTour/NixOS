# Tools: Monitoring, files, media, CLI utilities
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # === Monitoring ===
    btop

    # === Password Manager ===
    keepassxc

    # === Cloud Sync ===
    rclone

    # === File Manager ===
    yazi
    ffmpegthumbnailer
    tumbler
    poppler-utils

    # === Media ===
    imv          # Image viewer
    zathura      # PDF viewer
    mpv          # Video player

    # === CLI Utilities ===
    nano         # Emergency editor
    dust         # Disk usage analyzer
    fd           # Find replacement
    ripgrep      # Grep replacement
    eza          # ls replacement
    bat          # cat replacement
    unzip
    zip
    curl
    wget
    psmisc       # killall
    jq           # JSON processor

    # === System Info ===
    fastfetch    # System info display

    # === Search ===
    fsearch      # Everything-Alternative (GUI)

    # === Disk Usage ===
    gdu          # Interactive disk usage analyzer

    # === Network ===
    speedtest-cli  # Internet speed test
    iftop          # Network bandwidth monitor

    # === Help ===
    tldr         # Simplified man pages

    # === System ===
    nh           # Nix helper
  ];

  # Fast file search with plocate
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };
}
