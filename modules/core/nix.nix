# Nix configuration: Flakes, GC, general settings
{ pkgs, userConfig, ... }:

{
  # System state version
  system.stateVersion = "24.11";

  # Timezone and locale from config.nix
  time.timeZone = userConfig.timezone;
  i18n.defaultLocale = userConfig.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = userConfig.locale;
    LC_IDENTIFICATION = userConfig.locale;
    LC_MEASUREMENT = userConfig.locale;
    LC_MONETARY = userConfig.locale;
    LC_NAME = userConfig.locale;
    LC_NUMERIC = userConfig.locale;
    LC_PAPER = userConfig.locale;
    LC_TELEPHONE = userConfig.locale;
    LC_TIME = userConfig.locale;
  };

  # Console keymap from config.nix
  console.keyMap = userConfig.keyboardLayout;

  # Enable Flakes and nix-command
  # Allow unfree packages (JetBrains, Chrome, etc.)
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Graphics/OpenGL
  hardware.graphics.enable = true;

  # Sound (Pipewire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # VMware guest is now in modules/optional/vmware.nix
  # and controlled by userConfig.features.vmwareGuest
}
