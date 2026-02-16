# Network configuration: NetworkManager, DNS-over-TLS
{ pkgs, userConfig, ... }:

{
  # Hostname
  networking.hostName = userConfig.hostname;

  # NetworkManager
  networking.networkmanager.enable = true;

  # Disable wait-online service (faster boot)
  systemd.services.NetworkManager-wait-online.enable = false;

  # DNS-over-TLS with Quad9
  networking.nameservers = [ "9.9.9.9" "149.112.112.112" ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      Domains = [ "~." ];
      DNSOverTLS = "strict";
    };
  };
}
