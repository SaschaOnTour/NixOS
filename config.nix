# config.nix - NUTZERKONFIGURATION
# =================================
# Diese Datei VOR der Installation anpassen!

{
  # === PFLICHTFELDER ===

  # System-Benutzername (nur Kleinbuchstaben, keine Leerzeichen)
  username = "deinname";

  # Rechnername (wird in der Shell und im Netzwerk angezeigt)
  hostname = "nixos";

  # Ziel-Festplatte für die Installation
  # WICHTIG: Mit 'lsblk' den korrekten Pfad ermitteln!
  # Beispiele: "/dev/nvme0n1", "/dev/sda", "/dev/vda"
  disk = "/dev/nvme0n1";

  # Swap-Größe für Hibernation (Suspend-to-Disk)
  # Muss >= RAM-Größe sein, z.B. "16G", "32G", "64G"
  swapSize = "36G";

  # === GIT ===

  git = {
    userName = "Dein Name";
    userEmail = "dein@email.de";
  };

  # === REGION ===

  timezone = "Europe/Berlin";
  locale = "de_DE.UTF-8";
  keyboardLayout = "de";

  # === FEATURE-FLAGS ===

  features = {
    # Entwicklungstools aktivieren?
    # Enthält: JetBrains IDEs, Docker, Rust, .NET, Java, Node.js, Zed Editor
    development = true;

    # Desktop-Umgebung aktivieren?
    # Enthält: Niri (Wayland Compositor), Waybar, Fuzzel, Mako
    # Auf 'false' setzen für Server/Headless-Systeme
    desktop = true;

    # VMware Guest Additions aktivieren?
    # Nur auf 'true' setzen wenn NixOS in einer VMware VM läuft
    vmwareGuest = false;

    # AI Coding-Assistenten
    ai = {
      claudeCode = true;     # Anthropic Claude Code CLI
      chatgptCodex = true;   # OpenAI Codex CLI
      openCode = true;       # OpenCode CLI
    };
  };

  # === OPTIONAL ===

  # Hintergrundbild für Login-Bildschirm (relativ zum Home-Verzeichnis)
  # null = Standard-Hintergrund verwenden
  wallpaper = "Pictures/wallpaper.jpg";
}
