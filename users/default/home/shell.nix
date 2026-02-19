# Fish shell configuration
{ pkgs, userConfig, ... }:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      ll = "eza -l";
      la = "eza -la";
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      dc = "docker-compose";
      cat = "bat";
      find = "fd";
      grep = "rg";

      # Nix helpers
      os-switch = "nh os switch ~/Projects/nixos-config";
      os-update = "nh os switch --update ~/Projects/nixos-config";

      # Rust shortcuts
      ctest = "cargo nextest run";
      cov = "cargo llvm-cov";

      # Midnight Commander
      mcdiff = "mcdiff -u";
    };

    interactiveShellInit = ''
      set fish_greeting
      direnv hook fish | source
    '';
  };

  # Direnv for automatic environment loading
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Zoxide (smart cd)
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Starship prompt (optional, Fish has good default)
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Session environment variables
  home.sessionVariables = {
    KEYBOARD_KEY_TIMEOUT_US = "50000";
  };

  # Midnight Commander skin
  xdg.configFile."mc/ini".text = ''
    [Midnight-Commander]
    skin=dark
  '';

  # Git configuration from config.nix
  programs.git = {
    enable = true;
    settings = {
      user.name = userConfig.git.userName;
      user.email = userConfig.git.userEmail;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
