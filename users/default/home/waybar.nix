# Waybar configuration with CPU, RAM, Disk, clock
{ pkgs, style, ... }:

{
  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "${style.fonts.default} Nerd Font";
        font-size: 14px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: ${style.colors.background};
        color: ${style.colors.text};
        opacity: 0.95;
      }

      #workspaces button {
        padding: 0 8px;
        color: ${style.colors.text};
        background: transparent;
      }

      #workspaces button:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      #workspaces button.active {
        color: ${style.colors.primary};
        border-bottom: 2px solid ${style.colors.primary};
      }

      #clock, #cpu, #memory, #disk, #battery, #network, #tray {
        padding: 0 12px;
      }

      #cpu {
        color: ${style.colors.warning};
      }

      #memory {
        color: ${style.colors.secondary};
      }

      #disk {
        color: ${style.colors.success};
      }

      #battery.charging {
        color: ${style.colors.success};
      }

      #battery.warning:not(.charging) {
        color: ${style.colors.warning};
      }

      #battery.critical:not(.charging) {
        color: ${style.colors.error};
      }

      #network.disconnected {
        color: ${style.colors.error};
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
      }
    '';

    settings = [{
      layer = "top";
      position = "top";
      height = 32;
      spacing = 0;

      modules-left = [ "niri/workspaces" "niri/window" ];
      modules-center = [ "clock" ];
      modules-right = [ "cpu" "memory" "disk" "network" "battery" "tray" ];

      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "󰲠";
          "2" = "󰲢";
          "3" = "󰲤";
          "4" = "󰲦";
          "5" = "󰲨";
          default = "󰧞";
        };
      };

      "niri/window" = {
        max-length = 50;
        separate-outputs = true;
      };

      clock = {
        format = "󰥔 {:%H:%M}";
        format-alt = "󰃭 {:%A, %d. %B %Y}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          format = {
            months = "<span color='${style.colors.primary}'><b>{}</b></span>";
            days = "<span color='${style.colors.text}'>{}</span>";
            weeks = "<span color='${style.colors.secondary}'><b>W{}</b></span>";
            weekdays = "<span color='${style.colors.warning}'><b>{}</b></span>";
            today = "<span color='${style.colors.primary}'><b><u>{}</u></b></span>";
          };
        };
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 2;
        tooltip = true;
      };

      memory = {
        format = "󰍛 {percentage}%";
        format-alt = "󰍛 {used:0.1f}G / {total:0.1f}G";
        interval = 2;
        tooltip = true;
      };

      disk = {
        format = "󰋊 {percentage_used}%";
        format-alt = "󰋊 {used} / {total}";
        path = "/";
        interval = 30;
      };

      network = {
        format-wifi = "󰖩 {signalStrength}%";
        format-ethernet = "󰈀 {ifname}";
        format-disconnected = "󰖪 ";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
        tooltip-format = "{essid} ({signalStrength}%)\n{ifname}: {ipaddr}";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format = "{timeTo}\n{power}W";
      };

      tray = {
        icon-size = 18;
        spacing = 8;
      };
    }];
  };
}
