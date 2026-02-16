# VMware Guest Additions
# Nur aktivieren wenn NixOS in einer VMware VM läuft
{ ... }:

{
  virtualisation.vmware.guest.enable = true;
}
