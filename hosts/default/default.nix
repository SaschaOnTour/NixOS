# Host configuration - Imports with Feature Flags
{ lib, userConfig, ... }:

{
  imports = [
    # Disk configuration (always required)
    ./disko-config.nix

    # Core system modules (always required)
    ../../modules/core/boot.nix
    ../../modules/core/security.nix
    ../../modules/core/network.nix
    ../../modules/core/nix.nix

    # User configuration (always required)
    ../../users/default/system.nix
  ]
  # Desktop modules (optional)
  ++ (lib.optionals userConfig.features.desktop [
    ../../modules/desktop/niri.nix
    ../../modules/desktop/greetd.nix
    ../../modules/desktop/wayland.nix
    ../../modules/programs/browsers.nix
  ])
  # Development tools (optional)
  ++ (lib.optionals userConfig.features.development [
    ../../modules/programs/development.nix
  ])
  # Common programs (always useful)
  ++ [
    ../../modules/programs/tools.nix
    ../../modules/programs/scripts.nix
    ../../modules/programs/ai-tools.nix
  ]
  # VMware guest additions (optional)
  ++ (lib.optionals userConfig.features.vmwareGuest [
    ../../modules/optional/vmware.nix
  ]);
}
