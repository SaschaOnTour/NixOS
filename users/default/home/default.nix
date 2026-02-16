# Home Manager entry point
{ pkgs, inputs, style, userConfig, ... }:

{
  imports = [
    ./shell.nix
    ./ghostty.nix
    ./theme.nix
    ./niri.nix
    ./waybar.nix
  ];

  home.stateVersion = "24.11";
  home.username = userConfig.username;
  home.homeDirectory = "/home/${userConfig.username}";

  # Enable Home Manager
  programs.home-manager.enable = true;
}
