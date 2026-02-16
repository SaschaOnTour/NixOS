# Niri configuration: Compositor setup without niri-flake NixOS module
{ pkgs, inputs, ... }:

{
  # Install niri from the flake overlay
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # Install niri and session files
  environment.systemPackages = [ pkgs.niri ];

  # XWayland for legacy X11 apps
  programs.xwayland.enable = true;

  # XDG Portal configuration for screen sharing etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # Required services for Wayland compositors
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Session entry for greetd/display managers
  services.displayManager.sessionPackages = [ pkgs.niri ];
}
