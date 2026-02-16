# VMware Guest Additions
# Only enable if NixOS runs inside a VMware VM
{ ... }:

{
  virtualisation.vmware.guest.enable = true;
}
