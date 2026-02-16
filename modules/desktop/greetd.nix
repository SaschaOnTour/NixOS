# Greetd configuration: Login manager
# Uses tuigreet (TUI) for VMware, ReGreet (GTK4) for bare metal
{ pkgs, lib, userConfig, style, ... }:

let
  useReGreet = !userConfig.features.vmwareGuest;

  # Build wallpaper path if configured, otherwise use null
  wallpaperPath =
    if userConfig.wallpaper != null
    then "/persist/home/${userConfig.username}/${userConfig.wallpaper}"
    else null;
in
{
  # ReGreet (GTK4 greeter via cage) — only on bare metal
  programs.regreet = lib.mkIf useReGreet {
    enable = true;
    settings = {
      background = {
        path = wallpaperPath;
        fit = "Cover";
        color = style.colors.background;
      };
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = lib.mkForce style.gtkTheme;
        icon_theme_name = lib.mkForce style.iconTheme;
        font_name = lib.mkForce "${style.fonts.default} ${toString style.fonts.size}";
      };
    };
  };

  # tuigreet (TUI greeter) — for VMware where cage/GTK4 fails
  services.greetd = lib.mkIf (!useReGreet) {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = lib.mkIf (!useReGreet) [ pkgs.greetd.tuigreet ];

  # Ensure greeter can start Niri
  environment.etc."greetd/environments".text = ''
    niri-session
  '';
}
