# Style configuration - Theming and visual settings
# This file contains ONLY visual settings (colors, fonts, etc.)
# User-specific values are in config.nix
{
  # Color scheme (Dracula-inspired)
  colors = {
    primary = "#bd93f9";
    secondary = "#ff79c6";
    background = "#282a36";
    text = "#f8f8f2";
    error = "#ff5555";
    warning = "#f1fa8c";
    success = "#50fa7b";
  };

  # Font settings
  fonts = {
    default = "JetBrainsMono";
    size = 13;
  };

  # Default applications
  browser = "vivaldi";
  terminal = "ghostty";
  editor = "zed";

  # Theme settings
  gtkTheme = "Adwaita-dark";
  iconTheme = "Adwaita";
  terminalTheme = "Dracula";
}
