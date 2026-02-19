# Browser configuration: Zen, Helium, Tor, Flatpak
{ pkgs, inputs, ... }:

let
  zen-browser = inputs.zen-browser.packages.${pkgs.system}.default;
  helium = inputs.helium.packages.${pkgs.system}.default;

  ephemeralBrowser = pkgs.writeShellScriptBin "ephemeral-browser" ''
    TMPDIR=$(mktemp -d)
    ${zen-browser}/bin/zen --profile "$TMPDIR" --no-remote "$@"
    rm -rf "$TMPDIR"
  '';
in
{
  environment.systemPackages = [
    # Browsers
    zen-browser
    helium
    pkgs.tor-browser

    # Ephemeral browser script
    ephemeralBrowser
  ];

  # Zen Browser policies (Firefox-based policy engine)
  environment.etc."zen/policies/policies.json".text = builtins.toJSON {
    policies = {
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "gdpr@cavi.au.dk" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/consent-o-matic/latest.xpi";
          installation_mode = "force_installed";
        };
        "{74145f27-f039-47ce-a470-a662b129930a}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi";
          installation_mode = "force_installed";
        };
        "{b86e4813-687a-43e6-ab65-0bde4ab75758}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/localcdn-fork-of-decentraleyes/latest.xpi";
          installation_mode = "force_installed";
        };
        "keepassxc-browser@keepassxc.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
          installation_mode = "force_installed";
        };
      };
      DisableTelemetry = true;
      DNSOverHTTPS = {
        Enabled = false;
      };
    };
  };

  # Flatpak support
  services.flatpak.enable = true;

  # Note: XDG Portal is configured in modules/desktop/niri.nix
}
