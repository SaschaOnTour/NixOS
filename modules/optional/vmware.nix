# VMware Guest Additions
# Only enable if NixOS runs inside a VMware VM
{ ... }:

{
  virtualisation.vmware.guest.enable = true;

  # Use software renderer — vmwgfx/SVGA3D hangs with Wayland compositors
  environment.variables.WLR_RENDERER = "pixman";
}
