<div align="center">

# 🏰 Fort Knox NixOS

**A security-hardened, reproducible NixOS developer workstation.**

[![NixOS](https://img.shields.io/badge/NixOS-24.11-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue?logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![Wayland](https://img.shields.io/badge/Wayland-Niri-orange)](https://github.com/YaLTeR/niri)

*Boot clean. Every time. Your data persists — everything else is rebuilt from code.*

</div>

---

## ✨ Highlights

🔒 **Impermanence** — Root filesystem wiped on every boot, eliminating config drift
🛡️ **Full-disk encryption** — LUKS + LVM on Btrfs with encrypted hibernation
🧱 **Hardened kernel** — AppArmor enabled, firewall default deny-all
🖥️ **Niri compositor** — Modern scrolling tiling Wayland desktop with Waybar
🤖 **AI-ready** — Claude Code, ChatGPT Codex & OpenCode CLI out of the box
⚙️ **Modular** — Feature flags let you toggle dev tools, desktop, AI, and more

## 🧩 Feature Flags

Everything is toggled in a single `config.nix`:

```nix
{
  username = "yourname";
  hostname = "nixos";
  disk = "/dev/nvme0n1";
  swapSize = "36G";             # >= RAM for hibernation

  git = {
    userName = "Your Name";
    userEmail = "your@email.com";
  };

  features = {
    development = true;         # JetBrains, Docker, Rust, .NET, Node.js, Zed
    desktop = true;             # Niri, Waybar, VLC, OBS, LocalSend, browsers
    vmwareGuest = false;        # VMware guest additions
    ai = {
      claudeCode = true;       # Anthropic Claude Code CLI
      chatgptCodex = true;     # OpenAI Codex CLI
      openCode = true;         # OpenCode CLI
    };
  };
}
```

| Flag | What you get |
|------|-------------|
| `development` | JetBrains IDEs, Docker, Rust, .NET, Java, Node.js, Zed, lazygit |
| `desktop` | Niri, Waybar, Fuzzel, Mako, VLC, OBS, LocalSend, Vivaldi, Firefox |
| `vmwareGuest` | VMware Guest Additions |
| `ai.*` | Claude Code, ChatGPT Codex, OpenCode CLIs |

> **Headless server?** Set all feature flags to `false` — you get a minimal, encrypted, hardened server.

## 🚀 Quick Start

### Prerequisites

- UEFI system (no Legacy BIOS)
- NixOS Live USB (23.11+)
- ≥ 50 GB disk space

### Install (Interactive)

Boot the NixOS Live USB, connect to the internet, then run:

```bash
nix-shell -p git curl
curl -sL https://raw.githubusercontent.com/SaschaOnTour/NixOS/main/install.sh -o /tmp/install.sh
sudo bash /tmp/install.sh
```

The installer guides you through everything — disk selection, configuration, encryption, and installation. No second screen needed.

<details>
<summary><strong>Manual installation</strong></summary>

```bash
# 1. Enable flakes
export NIX_CONFIG="experimental-features = nix-command flakes"

# 2. Clone & configure
git clone https://github.com/SaschaOnTour/NixOS.git /tmp/nixos-config
cd /tmp/nixos-config
nano config.nix

# 3. Partition & encrypt disk (⚠️ WIPES TARGET DISK)
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko -- --mode disko --flake .#hostname

# 4. Install NixOS
sudo nixos-install --flake .#hostname --no-root-passwd

# 5. Reboot & set password
reboot
passwd yourname
```

</details>

> 📖 **New to NixOS?** There's a detailed [Beginner's Guide](#-beginners-guide) below covering every step from flashing the USB to your first desktop session.

## 🔄 After Installation: Setup & Updates

### First thing after install: Clone your config

The installer uses `/tmp` which doesn't survive reboots. Clone your config to a persistent location:

```bash
cd ~/Projects
git clone https://github.com/SaschaOnTour/NixOS.git nixos-config
```

> **Important:** The shell aliases `os-switch` and `os-update` expect the config at `~/Projects/nixos-config`. Always clone to exactly this path.

### Applying config changes

After editing your config or pulling updates:

```bash
os-switch              # Apply changes (runs: nh os switch ~/Projects/nixos-config)
```

No reboot needed — changes are applied immediately (except kernel updates). You can run `os-switch` from any directory.

### Updating all packages

```bash
os-update              # Update flake inputs + rebuild (runs: nh os switch --update ~/Projects/nixos-config)
```

### Rollback

If something breaks:

```bash
sudo nixos-rebuild switch --rollback
```

## 📁 Project Structure

```
.
├── config.nix              # ← Your single config file
├── style.nix               # Theming (colors, fonts)
├── flake.nix               # Flake definition
├── hosts/default/          # Host & disk configuration
├── modules/
│   ├── core/               # Boot, security, networking, impermanence
│   ├── desktop/            # Niri, Greetd, Wayland tools, media apps
│   ├── programs/           # Browsers, dev tools, AI tools, CLI utilities
│   └── optional/           # VMware
└── users/default/          # User & Home Manager configuration
```

## 🔐 How Impermanence Works

The root filesystem (`/`) is wiped on every reboot. Only explicitly declared paths survive:

**Persisted system paths:** `/var/log`, `/var/lib/docker`, `/etc/NetworkManager/system-connections`, and more.

**Persisted user paths:** `~/Projects`, `~/Documents`, `~/Downloads`, `~/.ssh`, browser profiles, IDE configs, build caches (`~/.cargo`, `~/.m2`, `~/.nuget`), AI tool configs (`~/.claude`, `~/.codex`).

Everything is defined in `modules/core/security.nix` — add a path, run `os-switch`, done.

## 🖥️ Desktop & Keybindings

Niri is a **scrolling tiling** compositor — windows are arranged in columns that scroll horizontally like a filmstrip.

| Shortcut | Action |
|----------|--------|
| `Mod+Return` | Terminal (Ghostty) |
| `Mod+Space` | App launcher (Fuzzel) |
| `Mod+B` | Browser |
| `Mod+E` | Editor (Zed) |
| `Mod+Q` | Close window |
| `Mod+F` | Maximize |
| `Mod+Left/Right` | Navigate columns |
| `Mod+1`–`5` | Switch workspace |
| `Mod+P` | Power menu |
| `Mod+Escape` | Lock screen |

## 🧰 Included Tools

**CLI:** `eza`, `bat`, `fd`, `ripgrep`, `jq`, `yazi`, `btop`, `dust`, `zoxide`, `tldr`, `lazygit`, `lazydocker`, `gh`
**Desktop:** VLC, OBS Studio, mpv, imv, zathura, KeePassXC, LocalSend, FSearch
**Dev:** JetBrains Rider/IntelliJ/RustRover, Zed, Docker, Rust, .NET, Java, Node.js
**AI:** Claude Code, ChatGPT Codex, OpenCode
**Shell:** Fish with pre-configured aliases, starship prompt, zoxide directory jumping

---

## 📖 Beginner's Guide

<details>
<summary><strong>Click to expand the full step-by-step walkthrough</strong></summary>

### Step-by-Step Installation

#### 1. Download NixOS ISO

Go to [nixos.org/download](https://nixos.org/download/) and grab the **Minimal ISO** (not GNOME/KDE — this config installs its own desktop).

#### 2. Flash USB

```bash
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Or use [Ventoy](https://ventoy.net) / [Balena Etcher](https://etcher.balena.io).

#### 3. Boot & Connect

Boot from USB via UEFI menu (F2/F12/Del). For WiFi, run `nmtui`.

Verify: `curl -sI https://nixos.org` — if you see HTTP headers, you're connected.

#### 4. Run the Installer

```bash
nix-shell -p git curl
curl -sL https://raw.githubusercontent.com/SaschaOnTour/NixOS/main/install.sh -o /tmp/install.sh
sudo bash /tmp/install.sh
```

The interactive installer walks you through disk selection, username, hostname, swap size, git config, and feature flags. It then partitions the disk, sets up encryption, and installs NixOS — all in one guided flow.

After installation, it prompts you to reboot. Then set your password:

```bash
passwd yourname
```

### What Disko Creates

- 512M EFI boot partition
- Encrypted LUKS container with LVM
- Swap partition (your configured size, for hibernation)
- Btrfs root with subvolumes

### First Boot — What to Expect

1. **GRUB** → **LUKS password** → **Login screen** (ReGreet) → **Niri desktop**
2. Press `Mod+Return` to open a terminal
3. Windows tile in scrollable columns — navigate with `Mod+Left/Right`

### How Niri's Scrolling Tiling Works

```
   [off-screen] ← [Column A] [Column B] [Column C] → [off-screen]
                    ^^^^^^^^   ^^^^^^^^
                    visible    visible
```

Unlike i3/Sway, Niri doesn't squeeze all windows onto one screen. Columns extend infinitely left and right — you scroll through them.

### Common Tasks

| Task | How |
|------|-----|
| Install a package | Add to a `.nix` file → `os-switch` |
| Change a keybinding | Edit `users/default/home/niri.nix` → `os-switch` |
| Persist a new directory | Edit `modules/core/security.nix` → `os-switch` |
| Rollback a broken change | `sudo nixos-rebuild switch --rollback` |
| Update everything | `os-update` |

### Shell Aliases

| Alias | Description |
|-------|-------------|
| `ll` / `la` | File listing (eza) |
| `cat` | Syntax-highlighted viewer (bat) |
| `find` / `grep` | Fast search (fd / ripgrep) |
| `g` / `dc` | Short for git / docker-compose |
| `..` / `...` | Navigate up |
| `os-switch` | Apply config changes (`nh os switch ~/Projects/nixos-config`) |
| `os-update` | Update + apply (`nh os switch --update ~/Projects/nixos-config`) |
| `z <path>` | Smart directory jump (zoxide) |

</details>

---

## 🤝 Contributing

Issues and pull requests are welcome!

## 📄 License

[MIT](LICENSE)
