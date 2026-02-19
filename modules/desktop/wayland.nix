# Wayland tools: Waybar, Fuzzel, Mako, and utilities
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt Wayland support (needed for VLC, Qt apps on Wayland)
    kdePackages.qtwayland
    qt5.qtwayland

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

    # Email
    thunderbird

  ];

  # Wayland environment variables
  environment.sessionVariables = {
    # Electron/Chromium apps (Helium, VS Code, etc.) → use Wayland
    NIXOS_OZONE_WL = "1";
    # JetBrains IDEs → fix blank windows on tiling WMs
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # Qt apps → use Wayland
    QT_QPA_PLATFORM = "wayland";
    # SDL apps → use Wayland
    SDL_VIDEODRIVER = "wayland";
    # Clutter apps → use Wayland
    CLUTTER_BACKEND = "wayland";
    # GDK apps → prefer Wayland
    GDK_BACKEND = "wayland,x11";
  };

  # XDG portal for screen sharing, file dialogs etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # LocalSend (AirDrop-Alternative, opens firewall port automatically)
  programs.localsend.enable = true;

  # Polkit authentication agent
  security.polkit.enable = true;

  # Enable dconf (needed for GTK apps)
  programs.dconf.enable = true;
}
