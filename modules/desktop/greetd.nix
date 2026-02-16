# Greetd configuration: Login manager with ReGreet
{ pkgs, lib, userConfig, style, ... }:

let
  # Build wallpaper path if configured, otherwise use null
  wallpaperPath =
    if userConfig.wallpaper != null
    then "/persist/home/${userConfig.username}/${userConfig.wallpaper}"
    else null;
in
{
  # ReGreet configuration (automatically configures greetd + cage)
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = wallpaperPath;
        fit = "Cover";
        color = style.colors.background;  # Fallback color when path is null
      };
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = lib.mkForce style.gtkTheme;
        icon_theme_name = lib.mkForce style.iconTheme;
        font_name = lib.mkForce "${style.fonts.default} ${toString style.fonts.size}";
      };
    };
  };

  # Ensure greeter can start Niri
  environment.etc."greetd/environments".text = ''
    niri-session
  '';
}
