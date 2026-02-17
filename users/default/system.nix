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
    # Password file in /persist survives root-wipe reboots
    # Initial file created by install.sh with password "nixos"
    # Change password with: passwd (updates /persist/passwords/<username>)
    hashedPasswordFile = "/persist/passwords/${userConfig.username}";
  };

  # Ensure passwd writes to the persistent location
  users.mutableUsers = true;

  # Home Manager configuration
  home-manager = {
    extraSpecialArgs = { inherit inputs style userConfig; };
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${userConfig.username} = import ./home;
  };
}
