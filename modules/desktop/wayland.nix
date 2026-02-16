# Wayland tools: Waybar, Fuzzel, Mako, and utilities
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Status bar
    waybar

    # Application launcher
    fuzzel

    # Notifications
    mako
    libnotify

    # Wallpaper
    swww

    # Clipboard
    wl-clipboard
    cliphist

    # Screenshots
    grim
    slurp
    swappy

    # Screen locking & idle
    swaylock
    swayidle

    # Volume OSD
    avizo

    # Authentication agent
    polkit_gnome

    # Network applet
    networkmanagerapplet

    # Audio control
    pavucontrol

    # Media
    vlc
    obs-studio

  ];

  # LocalSend (AirDrop-Alternative, opens firewall port automatically)
  programs.localsend.enable = true;

  # Polkit authentication agent
  security.polkit.enable = true;

  # Enable dconf (needed for GTK apps)
  programs.dconf.enable = true;
}
