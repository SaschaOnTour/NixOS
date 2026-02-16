# Theme configuration: Fonts, GTK, cursor
{ pkgs, style, ... }:

{
  # Fonts
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.enable = true;

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = style.gtkTheme;
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = style.iconTheme;
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    font = {
      name = "${style.fonts.default}";
      size = style.fonts.size;
    };
  };

  # Qt theme (follow GTK)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
