# Niri user configuration: keybindings, window rules, autostart
{ pkgs, style, userConfig, ... }:

{
  programs.niri = {
    enable = true;

    settings = {
      # Environment variables for all apps launched from Niri
      environment = {
        NIXOS_OZONE_WL = "1";                    # Electron/Chromium → Wayland
        _JAVA_AWT_WM_NONREPARENTING = "1";       # JetBrains IDEs
        QT_QPA_PLATFORM = "wayland;xcb";         # Qt apps → Wayland first, X11 fallback
        SDL_VIDEODRIVER = "wayland";             # SDL apps
        CLUTTER_BACKEND = "wayland";             # Clutter apps
        GDK_BACKEND = "wayland,x11";             # GTK apps
        XDG_SESSION_TYPE = "wayland";
        DISPLAY = ":0";                          # XWayland display for legacy apps
      };

      # Keyboard layout
      input.keyboard.xkb.layout = userConfig.keyboardLayout;

      # Default background color (shown when no wallpaper is set)
      outputs."*".background-color = style.colors.background;

      # Autostart applications (use argv, not command)
      spawn-at-startup = [
        { argv = [ "xwayland-satellite" ]; }  # XWayland for legacy X11 apps
        { argv = [ "waybar" ]; }
        { argv = [ "mako" ]; }
        { argv = [ "swww-daemon" ]; }
        { argv = [ "sh" "-c" "sleep 1 && [ -f \"$HOME/${userConfig.wallpaper}\" ] && swww img \"$HOME/${userConfig.wallpaper}\"" ]; }
        { argv = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
        { argv = [ "nm-applet" "--indicator" ]; }
      ];

      # Window rules (window-rules, not window-rule)
      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 12.0;
            top-right = 12.0;
            bottom-left = 12.0;
            bottom-right = 12.0;
          };
          clip-to-geometry = true;
        }
        {
          matches = [{ app-id = "^Fuzzel$"; }];
          open-floating = true;
        }
        {
          matches = [{ app-id = "^pavucontrol$"; }];
          open-floating = true;
        }
      ];

      # Layout
      layout = {
        focus-ring.enable = false;
        border = {
          enable = true;
          width = 2;
          active.color = style.colors.primary;
          inactive.color = style.colors.background;
        };
        gaps = 8;
      };

      # Keybindings
      binds = {
        # Hotkey overlay (F1 = Help)
        "Mod+F1".action.show-hotkey-overlay = {};

        # Applications
        "Mod+Return".action.spawn = style.terminal;
        "Mod+Space".action.spawn = "fuzzel";
        "Mod+B".action.spawn = style.browser;
        "Mod+E".action.spawn = style.editor;
        "Mod+T".action.spawn = "thunderbird";
        "Mod+P".action.spawn = "niri-powermenu";

        # Window management
        "Mod+Q".action.close-window = {};
        "Mod+Shift+E".action.quit = {};

        # Focus
        "Mod+Left".action.focus-column-left = {};
        "Mod+Right".action.focus-column-right = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Down".action.focus-window-down = {};
        "Mod+J".action.focus-column-left = {};
        "Mod+L".action.focus-column-right = {};
        "Mod+I".action.focus-window-up = {};
        "Mod+K".action.focus-window-down = {};

        # Move windows
        "Mod+Shift+Left".action.move-column-left = {};
        "Mod+Shift+Right".action.move-column-right = {};
        "Mod+Shift+Up".action.move-window-up = {};
        "Mod+Shift+Down".action.move-window-down = {};
        "Mod+Shift+J".action.move-column-left = {};
        "Mod+Shift+L".action.move-column-right = {};
        "Mod+Shift+I".action.move-window-up = {};
        "Mod+Shift+K".action.move-window-down = {};

        # Workspaces
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;

        # Workspace navigation (sequential)
        "Mod+Z".action.focus-workspace-up = {};
        "Mod+H".action.focus-workspace-down = {};
        "Mod+Shift+Z".action.move-column-to-workspace-up = {};
        "Mod+Shift+H".action.move-column-to-workspace-down = {};
        "Mod+Page_Up".action.focus-workspace-up = {};
        "Mod+Page_Down".action.focus-workspace-down = {};
        "Mod+Shift+Page_Up".action.move-column-to-workspace-up = {};
        "Mod+Shift+Page_Down".action.move-column-to-workspace-down = {};

        # Layout
        "Mod+F".action.maximize-column = {};
        "Mod+Shift+F".action.fullscreen-window = {};

        # Screenshot
        "Print".action.screenshot = {};
        "Mod+Print".action.screenshot-screen = {};
        "Mod+Shift+Print".action.screenshot-window = {};

        # Audio (via avizo)
        "XF86AudioRaiseVolume".action.spawn = [ "volumectl" "-u" "up" ];
        "XF86AudioLowerVolume".action.spawn = [ "volumectl" "-u" "down" ];
        "XF86AudioMute".action.spawn = [ "volumectl" "toggle-mute" ];

        # Brightness (via avizo)
        "XF86MonBrightnessUp".action.spawn = [ "lightctl" "up" ];
        "XF86MonBrightnessDown".action.spawn = [ "lightctl" "down" ];

        # Lock screen
        "Mod+Escape".action.spawn = [ "loginctl" "lock-session" ];
      };
    };
  };

  # Fuzzel launcher config
  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=${style.fonts.default}:size=14
    terminal=${style.terminal} -e
    icon-theme=${style.iconTheme}
    width=40
    lines=10

    [colors]
    background=${builtins.substring 1 6 style.colors.background}ee
    text=${builtins.substring 1 6 style.colors.text}ff
    match=${builtins.substring 1 6 style.colors.primary}ff
    selection=${builtins.substring 1 6 style.colors.secondary}ff
    selection-text=${builtins.substring 1 6 style.colors.background}ff
    border=${builtins.substring 1 6 style.colors.primary}ff

    [border]
    width=2
    radius=12
  '';

  # Mako notification config
  services.mako = {
    enable = true;
    settings = {
      "" = {
        background-color = "${style.colors.background}ee";
        text-color = style.colors.text;
        border-color = style.colors.primary;
        border-radius = 12;
        border-size = 2;
        default-timeout = 5000;
        font = "${style.fonts.default} ${toString style.fonts.size}";
      };
    };
  };

  # Swaylock config
  programs.swaylock = {
    enable = true;
    settings = {
      color = builtins.substring 1 6 style.colors.background;
      font = style.fonts.default;
      font-size = 24;
      indicator-idle-visible = true;
      indicator-radius = 100;
      indicator-thickness = 10;
      inside-color = "1a1b2680";
      inside-clear-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";
      key-hl-color = builtins.substring 1 6 style.colors.primary;
      bs-hl-color = builtins.substring 1 6 style.colors.error;
      ring-color = builtins.substring 1 6 style.colors.text;
      ring-clear-color = builtins.substring 1 6 style.colors.warning;
      ring-ver-color = builtins.substring 1 6 style.colors.primary;
      ring-wrong-color = builtins.substring 1 6 style.colors.error;
      line-uses-ring = true;
      show-failed-attempts = true;
    };
  };

  # Swayidle config
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock}/bin/swaylock -f"; }
      { timeout = 600; command = "niri msg action power-off-monitors"; }
    ];
  };
}
