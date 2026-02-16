# Browser configuration: Vivaldi, Chrome, Tor, Flatpak
{ pkgs, ... }:

let
  ephemeralBrowser = pkgs.writeShellScriptBin "ephemeral-browser" ''
    TMPDIR=$(mktemp -d)
    ${pkgs.vivaldi}/bin/vivaldi --user-data-dir="$TMPDIR" --no-first-run "$@"
    rm -rf "$TMPDIR"
  '';
in
{
  environment.systemPackages = with pkgs; [
    # Browsers
    vivaldi
    google-chrome
    tor-browser

    # Ephemeral browser script
    ephemeralBrowser
  ];

  # Flatpak support
  services.flatpak.enable = true;

  # Note: XDG Portal is configured in modules/desktop/niri.nix
}
