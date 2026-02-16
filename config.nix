# config.nix - USER CONFIGURATION
# =================================
# Edit this file BEFORE installation!

{
  # === REQUIRED FIELDS ===

  # System username (lowercase only, no spaces)
  username = "yourname";

  # Hostname (shown in shell prompt and network)
  hostname = "nixos";

  # Target disk for installation
  # IMPORTANT: Use 'lsblk' to find the correct path!
  # Examples: "/dev/nvme0n1", "/dev/sda", "/dev/vda"
  disk = "/dev/nvme0n1";

  # Swap size for hibernation (suspend-to-disk)
  # Must be >= RAM size, e.g. "16G", "32G", "64G"
  swapSize = "36G";

  # === GIT ===

  git = {
    userName = "Your Name";
    userEmail = "your@email.com";
  };

  # === REGION ===

  timezone = "Europe/Berlin";
  locale = "de_DE.UTF-8";
  keyboardLayout = "de";

  # === FEATURE FLAGS ===

  features = {
    # Enable development tools?
    # Includes: JetBrains IDEs, Docker, Rust, .NET, Java, Node.js, Zed Editor
    development = true;

    # Enable desktop environment?
    # Includes: Niri (Wayland Compositor), Waybar, Fuzzel, Mako
    # Set to 'false' for server/headless systems
    desktop = true;

    # Enable VMware Guest Additions?
    # Only set to 'true' if NixOS runs inside a VMware VM
    vmwareGuest = false;

    # AI coding assistants
    ai = {
      claudeCode = true;     # Anthropic Claude Code CLI
      chatgptCodex = true;   # OpenAI Codex CLI
      openCode = true;       # OpenCode CLI
    };
  };

  # === OPTIONAL ===

  # Wallpaper for login screen (relative to home directory)
  # null = use default wallpaper
  wallpaper = "Pictures/wallpaper.jpg";
}
