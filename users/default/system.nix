# User system configuration
{ pkgs, inputs, style, userConfig, ... }:

{
  # Enable Fish shell system-wide
  programs.fish.enable = true;

  # Create user
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.username;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
    # Initial password for first login — change immediately with: passwd
    initialPassword = "nixos";
  };

  # Home Manager configuration
  home-manager = {
    extraSpecialArgs = { inherit inputs style userConfig; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userConfig.username} = import ./home;
  };
}
