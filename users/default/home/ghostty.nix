# Ghostty terminal configuration
{ pkgs, style, ... }:

{
  home.packages = [ pkgs.ghostty ];

  xdg.configFile."ghostty/config".text = ''
    # Theme
    theme = ${style.terminalTheme}

    # Font
    font-family = ${style.fonts.default} Nerd Font
    font-size = ${toString style.fonts.size}

    # Window
    window-decoration = false
    confirm-close-surface = false
    minimum-columns = 80
    minimum-rows = 24

    # Shell
    shell-integration = fish

    # Cursor
    cursor-style = block
    cursor-style-blink = true

    # Scrollback
    scrollback-limit = 10000
  '';
}
