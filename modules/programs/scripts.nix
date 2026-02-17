# Custom scripts: Powermenu, change-password
{ pkgs, userConfig, ... }:

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

  # Password change script that persists across reboots (impermanence)
  change-password = pkgs.writeShellScriptBin "change-password" ''
    USER="$(whoami)"
    PERSIST_FILE="/persist/passwords/$USER"

    echo "Changing password for $USER"
    echo ""

    # Read new password
    read -s -p "New password: " pass1
    echo ""
    read -s -p "Confirm password: " pass2
    echo ""

    if [ "$pass1" != "$pass2" ]; then
      echo "Error: passwords don't match."
      exit 1
    fi

    if [ -z "$pass1" ]; then
      echo "Error: password cannot be empty."
      exit 1
    fi

    # Generate hash and write to persistent storage
    HASH=$(echo "$pass1" | ${pkgs.mkpasswd}/bin/mkpasswd -m sha-512 --stdin)
    echo "$HASH" | sudo tee "$PERSIST_FILE" > /dev/null
    sudo chmod 600 "$PERSIST_FILE"

    # Also update the current session so it takes effect immediately
    echo "$USER:$pass1" | sudo chpasswd

    echo "Password updated (persists across reboots)."
  '';
in
{
  environment.systemPackages = [ powermenu change-password ];
}
