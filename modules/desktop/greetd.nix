# Greetd configuration: Login manager with ReGreet
{ pkgs, userConfig, style, ... }:

let
  # Build wallpaper path if configured, otherwise use null
  wallpaperPath =
    if userConfig.wallpaper != null
    then "/persist/home/${userConfig.username}/${userConfig.wallpaper}"
    else null;
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # ReGreet is a GTK4 greeter
        command = "${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # ReGreet configuration
  programs.regreet = {
    enable = true;
    settings = {
      background = {
        path = wallpaperPath;
        fit = "Cover";
      };
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = style.gtkTheme;
        icon_theme_name = style.iconTheme;
        font_name = "${style.fonts.default} ${toString style.fonts.size}";
      };
    };
  };

  # Ensure greeter can start Niri
  environment.etc."greetd/environments".text = ''
    niri-session
  '';
}
