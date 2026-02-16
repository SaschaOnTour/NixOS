# Custom scripts: Powermenu for Fuzzel
{ pkgs, ... }:

let
  powermenu = pkgs.writeShellScriptBin "niri-powermenu" ''
    SELECTION="$(printf "Logout\nLock\nHibernate\nReboot\nShutdown" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "Action: " -w 20 -l 5)"

    case "$SELECTION" in
      "Logout")
        niri msg action quit
        ;;
      "Lock")
        loginctl lock-session
        ;;
      "Hibernate")
        systemctl hibernate
        ;;
      "Reboot")
        systemctl reboot
        ;;
      "Shutdown")
        systemctl poweroff
        ;;
    esac
  '';
in
{
  environment.systemPackages = [ powermenu ];
}
