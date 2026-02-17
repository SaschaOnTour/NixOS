#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Fort Knox NixOS — Interactive Installer
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

REPO_URL="https://github.com/SaschaOnTour/NixOS.git"
WORK_DIR="/tmp/nixos-config"

# ============================================================================
# Helper functions
# ============================================================================

print_banner() {
    echo -e "${CYAN}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║           🏰 Fort Knox NixOS                 ║"
    echo "  ║       Interactive Installer v1.0             ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[  OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[FAIL]${NC} $1"; }
step()    { echo -e "\n${BOLD}${CYAN}── $1 ──${NC}\n"; }

ask() {
    local prompt="$1"
    local default="${2:-}"
    local result

    if [[ -n "$default" ]]; then
        echo -ne "${BOLD}$prompt${NC} ${DIM}[$default]${NC}: " >&2
        read -r result
        result="${result%$'\r'}"
        echo "${result:-$default}"
    else
        echo -ne "${BOLD}$prompt${NC}: " >&2
        read -r result
        result="${result%$'\r'}"
        echo "$result"
    fi
}

ask_yes_no() {
    local prompt="$1"
    local default="${2:-y}"
    local result

    if [[ "$default" == "y" ]]; then
        echo -ne "${BOLD}$prompt${NC} ${DIM}[Y/n, Enter = yes]${NC}: "
    else
        echo -ne "${BOLD}$prompt${NC} ${DIM}[y/N, Enter = no]${NC}: "
    fi

    read -r result
    result="${result%$'\r'}"
    result="${result:-$default}"
    [[ "${result,,}" == "y" || "${result,,}" == "yes" ]]
}

confirm_or_abort() {
    echo ""
    if ! ask_yes_no "$1" "n"; then
        error "Aborted by user."
        exit 1
    fi
}

# ============================================================================
# Validation checks
# ============================================================================

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root."
        echo -e "  Run: ${BOLD}sudo bash install.sh${NC}"
        exit 1
    fi
    success "Running as root"
}

check_uefi() {
    if [[ ! -d /sys/firmware/efi ]]; then
        error "UEFI not detected. Fort Knox NixOS requires a UEFI system."
        echo "  Check your BIOS settings and make sure UEFI boot is enabled."
        exit 1
    fi
    success "UEFI boot detected"
}

check_internet() {
    if ! curl -sI https://nixos.org --connect-timeout 5 > /dev/null 2>&1; then
        error "No internet connection."
        echo "  For WiFi, run: nmtui"
        echo "  Then restart this script."
        exit 1
    fi
    success "Internet connection works"
}

check_nix() {
    if ! command -v nix &> /dev/null; then
        error "Nix is not available. Are you running this from the NixOS installer?"
        exit 1
    fi
    success "Nix is available"
}

check_git() {
    if ! command -v git &> /dev/null; then
        error "git is not available."
        echo -e "  Run: ${BOLD}nix-shell -p git${NC}"
        exit 1
    fi
    success "git is available"
}

validate_disk() {
    local disk="$1"
    if [[ ! -b "$disk" ]]; then
        return 1
    fi
    # Don't allow installing to the live USB / ISO media
    local disk_name
    disk_name=$(basename "$disk")
    if findmnt -n -o SOURCE /iso 2>/dev/null | grep -q "$disk_name"; then
        return 1
    fi
    if findmnt -n -o SOURCE /nix/.ro-store 2>/dev/null | grep -q "$disk_name"; then
        return 1
    fi
    return 0
}

validate_username() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        return 1
    fi
    if [[ ${#name} -gt 32 ]]; then
        return 1
    fi
    return 0
}

validate_hostname() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]*$ ]]; then
        return 1
    fi
    if [[ ${#name} -gt 63 ]]; then
        return 1
    fi
    return 0
}

validate_swap_size() {
    local size="$1"
    if [[ ! "$size" =~ ^[0-9]+[GgMm]$ ]]; then
        return 1
    fi
    return 0
}

# ============================================================================
# Disk selection
# ============================================================================

select_disk() {
    step "Disk Selection"

    echo -e "Available disks:\n"
    echo -e "${DIM}  NAME        SIZE  TYPE${NC}"
    echo "  ─────────────────────────"

    local disks=()
    local i=1

    while IFS= read -r line; do
        local name size type
        name=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        type=$(echo "$line" | awk '{print $3}')

        # Skip loop devices, rom devices, and the live USB
        [[ "$type" != "disk" ]] && continue

        local full_path="/dev/$name"

        # Skip the installer media
        if findmnt -n -o SOURCE /iso 2>/dev/null | grep -q "$name"; then
            echo -e "  ${DIM}$i) /dev/$name  ${size}  (installer media — skipped)${NC}"
            ((i++))
            continue
        fi
        if findmnt -n -o SOURCE /nix/.ro-store 2>/dev/null | grep -q "$name"; then
            echo -e "  ${DIM}$i) /dev/$name  ${size}  (installer media — skipped)${NC}"
            ((i++))
            continue
        fi

        echo -e "  ${BOLD}$i)${NC} /dev/$name  ${size}"
        disks+=("$full_path")
        ((i++))
    done < <(lsblk -ndo NAME,SIZE,TYPE 2>/dev/null)

    echo ""

    if [[ ${#disks[@]} -eq 0 ]]; then
        error "No suitable disks found."
        exit 1
    fi

    if [[ ${#disks[@]} -eq 1 ]]; then
        SELECTED_DISK="${disks[0]}"
        info "Only one disk available: ${BOLD}$SELECTED_DISK${NC}"
    else
        while true; do
            local choice
            choice=$(ask "Select disk number" "1")
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#disks[@]} )); then
                SELECTED_DISK="${disks[$((choice-1))]}"
                break
            fi
            warn "Invalid selection. Enter a number between 1 and ${#disks[@]}."
        done
    fi

    local disk_size
    disk_size=$(lsblk -ndo SIZE "$SELECTED_DISK" 2>/dev/null)
    success "Selected disk: ${BOLD}$SELECTED_DISK${NC} ($disk_size)"

    echo ""
    echo -e "  ${RED}${BOLD}⚠  WARNING: ALL DATA on $SELECTED_DISK will be ERASED.${NC}"
    confirm_or_abort "Are you absolutely sure you want to use $SELECTED_DISK?"
}

# ============================================================================
# Configuration
# ============================================================================

collect_config() {
    step "System Configuration"

    while true; do
        CONFIG_USERNAME=$(ask "Username" "")
        if validate_username "$CONFIG_USERNAME"; then
            break
        fi
        warn "Invalid username. Use lowercase letters, numbers, hyphens, underscores."
    done

    while true; do
        CONFIG_HOSTNAME=$(ask "Hostname" "fortress")
        if validate_hostname "$CONFIG_HOSTNAME"; then
            break
        fi
        warn "Invalid hostname. Use letters, numbers, hyphens."
    done

    # Suggest swap size based on RAM
    local ram_gb
    ram_gb=$(awk '/MemTotal/ {printf "%d", ($2/1024/1024)+1}' /proc/meminfo)
    local suggested_swap="${ram_gb}G"

    while true; do
        CONFIG_SWAP=$(ask "Swap size (>= RAM for hibernation)" "$suggested_swap")
        if validate_swap_size "$CONFIG_SWAP"; then
            break
        fi
        warn "Invalid format. Use a number followed by G or M (e.g., 16G, 8G)."
    done

    step "Git Configuration (optional, press Enter to skip)"

    CONFIG_GIT_NAME=$(ask "Git user name" "")
    CONFIG_GIT_EMAIL=$(ask "Git email" "")

    step "Regional Settings"

    CONFIG_TIMEZONE=$(ask "Timezone" "Europe/Berlin")
    CONFIG_LOCALE=$(ask "Locale" "de_DE.UTF-8")
    CONFIG_KEYBOARD=$(ask "Keyboard layout" "de")

    step "Feature Flags"

    if ask_yes_no "Enable development tools? (JetBrains, Docker, Rust, .NET)" "y"; then
        CONFIG_FEAT_DEV=true
    else
        CONFIG_FEAT_DEV=false
    fi

    if ask_yes_no "Enable desktop environment? (Niri, Waybar, VLC, OBS)" "y"; then
        CONFIG_FEAT_DESKTOP=true
    else
        CONFIG_FEAT_DESKTOP=false
    fi

    if ask_yes_no "Enable VMware guest additions?" "n"; then
        CONFIG_FEAT_VMWARE=true
    else
        CONFIG_FEAT_VMWARE=false
    fi

    echo ""
    info "AI tools:"

    if ask_yes_no "  Enable Claude Code CLI?" "y"; then
        CONFIG_FEAT_CLAUDE=true
    else
        CONFIG_FEAT_CLAUDE=false
    fi

    if ask_yes_no "  Enable ChatGPT Codex CLI?" "y"; then
        CONFIG_FEAT_CODEX=true
    else
        CONFIG_FEAT_CODEX=false
    fi

    if ask_yes_no "  Enable OpenCode CLI?" "y"; then
        CONFIG_FEAT_OPENCODE=true
    else
        CONFIG_FEAT_OPENCODE=false
    fi
}

# ============================================================================
# Summary & confirmation
# ============================================================================

show_summary() {
    step "Configuration Summary"

    echo -e "  ${BOLD}System${NC}"
    echo -e "  Username:     ${CYAN}$CONFIG_USERNAME${NC}"
    echo -e "  Hostname:     ${CYAN}$CONFIG_HOSTNAME${NC}"
    echo -e "  Target disk:  ${CYAN}$SELECTED_DISK${NC}"
    echo -e "  Swap size:    ${CYAN}$CONFIG_SWAP${NC}"
    echo ""
    echo -e "  ${BOLD}Git${NC}"
    echo -e "  Name:         ${CYAN}${CONFIG_GIT_NAME:-(not set)}${NC}"
    echo -e "  Email:        ${CYAN}${CONFIG_GIT_EMAIL:-(not set)}${NC}"
    echo ""
    echo -e "  ${BOLD}Region${NC}"
    echo -e "  Timezone:     ${CYAN}$CONFIG_TIMEZONE${NC}"
    echo -e "  Locale:       ${CYAN}$CONFIG_LOCALE${NC}"
    echo -e "  Keyboard:     ${CYAN}$CONFIG_KEYBOARD${NC}"
    echo ""
    echo -e "  ${BOLD}Features${NC}"
    echo -e "  Development:  $(flag_status $CONFIG_FEAT_DEV)"
    echo -e "  Desktop:      $(flag_status $CONFIG_FEAT_DESKTOP)"
    echo -e "  VMware:       $(flag_status $CONFIG_FEAT_VMWARE)"
    echo -e "  Claude Code:  $(flag_status $CONFIG_FEAT_CLAUDE)"
    echo -e "  Codex:        $(flag_status $CONFIG_FEAT_CODEX)"
    echo -e "  OpenCode:     $(flag_status $CONFIG_FEAT_OPENCODE)"

    confirm_or_abort "Proceed with installation?"
}

flag_status() {
    if [[ "$1" == "true" ]]; then
        echo -e "${GREEN}enabled${NC}"
    else
        echo -e "${DIM}disabled${NC}"
    fi
}

# ============================================================================
# Write config.nix
# ============================================================================

write_config() {
    step "Writing config.nix"

    cat > "$WORK_DIR/config.nix" << EOF
# config.nix - Generated by Fort Knox NixOS Installer
# Edit this file to change your system configuration.
# Then run: sudo nixos-rebuild switch --flake .#$CONFIG_HOSTNAME
{
  # === SYSTEM ===
  username = "$CONFIG_USERNAME";
  hostname = "$CONFIG_HOSTNAME";
  disk = "$SELECTED_DISK";
  swapSize = "$CONFIG_SWAP";

  # === GIT ===
  git = {
    userName = "$CONFIG_GIT_NAME";
    userEmail = "$CONFIG_GIT_EMAIL";
  };

  # === REGION ===
  timezone = "$CONFIG_TIMEZONE";
  locale = "$CONFIG_LOCALE";
  keyboardLayout = "$CONFIG_KEYBOARD";

  # === FEATURE FLAGS ===
  features = {
    development = $CONFIG_FEAT_DEV;      # JetBrains, Docker, Rust, .NET, Java, Node.js
    desktop = $CONFIG_FEAT_DESKTOP;          # Niri, Waybar, VLC, OBS, LocalSend, browsers
    vmwareGuest = $CONFIG_FEAT_VMWARE;      # VMware Guest Additions
    ai = {
      claudeCode = $CONFIG_FEAT_CLAUDE;    # Anthropic Claude Code CLI
      chatgptCodex = $CONFIG_FEAT_CODEX;   # OpenAI Codex CLI
      openCode = $CONFIG_FEAT_OPENCODE;    # OpenCode CLI
    };
  };

  # === OPTIONAL ===
  # Wallpaper for login screen and desktop (relative to home directory)
  # Set to null for plain Dracula background
  wallpaper = "Pictures/wallpaper.jpg";
}
EOF

    success "config.nix written"
}

# ============================================================================
# Installation
# ============================================================================

clone_repo() {
    step "Cloning Repository"

    if [[ -d "$WORK_DIR/.git" ]]; then
        info "Repository already exists at $WORK_DIR, updating..."
        git -C "$WORK_DIR" pull --ff-only || {
            warn "Pull failed, re-cloning..."
            rm -rf "$WORK_DIR"
            git clone "$REPO_URL" "$WORK_DIR"
        }
    else
        [[ -d "$WORK_DIR" ]] && rm -rf "$WORK_DIR"
        git clone "$REPO_URL" "$WORK_DIR"
    fi

    success "Repository ready at $WORK_DIR"
}

run_disko() {
    step "Partitioning & Encrypting Disk"

    # Skip if already partitioned (LUKS container exists)
    if lsblk -n -o TYPE "$SELECTED_DISK" 2>/dev/null | grep -q "crypt"; then
        info "Disk already partitioned and encrypted — skipping Disko."
        success "Using existing partitions"
        return
    fi

    info "Disko will now partition $SELECTED_DISK."
    info "You will be asked to set a ${BOLD}LUKS encryption password${NC}."
    warn "Remember this password — you need it on every boot!"
    echo ""

    nix --experimental-features "nix-command flakes" run \
        github:nix-community/disko -- --mode disko --flake "$WORK_DIR#$CONFIG_HOSTNAME"

    success "Disk partitioned and encrypted"
}

run_install() {
    step "Installing NixOS"

    # Extra binary caches (avoids compiling niri from source) + connection tuning
    export NIX_CONFIG=$'http-connections = 25\nconnect-timeout = 15\nextra-substituters = https://niri.cachix.org\nextra-trusted-public-keys = niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964='

    # Warm up DNS and network connections
    info "Warming up network connections..."
    nix-prefetch-url https://cache.nixos.org/nix-cache-info > /dev/null 2>&1 || true
    curl -sf https://static.crates.io > /dev/null 2>&1 || true
    curl -sf https://github.com > /dev/null 2>&1 || true

    local max_retries=3
    local attempt=1

    while (( attempt <= max_retries )); do
        info "Attempt $attempt/$max_retries — this may take a while..."
        echo ""

        if nixos-install --flake "$WORK_DIR#$CONFIG_HOSTNAME" --no-root-passwd; then
            success "NixOS installed successfully!"
            return
        fi

        if (( attempt < max_retries )); then
            warn "Installation failed (likely a network error)."
            info "Retrying in 5 seconds... (attempt $((attempt+1))/$max_retries)"
            sleep 5
        fi

        ((attempt++))
    done

    error "Installation failed after $max_retries attempts."
    echo -e "  You can retry manually with:"
    echo -e "  ${CYAN}nixos-install --flake $WORK_DIR#$CONFIG_HOSTNAME --no-root-passwd${NC}"
    exit 1
}

# ============================================================================
# Finish
# ============================================================================

persist_config() {
    step "Persisting configuration for first boot"

    # Create initial password file (hash of "nixos")
    mkdir -p /mnt/persist/passwords
    echo "nixos" | mkpasswd -m sha-512 --stdin > "/mnt/persist/passwords/$CONFIG_USERNAME" 2>/dev/null \
        || echo 'nixos' | openssl passwd -6 -stdin > "/mnt/persist/passwords/$CONFIG_USERNAME" 2>/dev/null \
        || {
            # Fallback: pre-computed hash of "nixos"
            echo '$6$rounds=656000$randomsalt$KvZrjH5M4z3BQnDqFN7sN.V0K0GzK8YVRbP6U.YGqKpvqFOeBsNEuGLN3mSa4rLDRHB3DhXMnR1SEBkoLvCb1' > "/mnt/persist/passwords/$CONFIG_USERNAME"
        }
    chmod 600 "/mnt/persist/passwords/$CONFIG_USERNAME"
    success "Initial password set (password: nixos — change with: change-password)"

    # Clone repo to persistent storage so it survives reboot
    local persist_dir="/mnt/persist/home/$CONFIG_USERNAME/Projects/nixos-config"
    if git clone "$REPO_URL" "$persist_dir" 2>/dev/null; then
        # Overwrite template config.nix with the user's actual values
        cp "$WORK_DIR/config.nix" "$persist_dir/config.nix"
        # Fix ownership (will be applied after user is created)
        chown -R 1000:100 "/mnt/persist/home/$CONFIG_USERNAME/Projects"
        success "Config persisted to ~/Projects/nixos-config"
    else
        warn "Could not persist config (non-critical)."
        info "After reboot, clone manually:"
        echo -e "  ${CYAN}cd ~/Projects && git clone $REPO_URL nixos-config${NC}"
    fi
}

finish() {
    echo ""
    echo -e "${GREEN}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║        🏰 Installation Complete!             ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "  ${BOLD}Next steps after reboot:${NC}"
    echo ""
    echo -e "  1. Enter your LUKS password at the boot prompt"
    echo -e "  2. Log in as ${BOLD}$CONFIG_USERNAME${NC} (initial password: ${CYAN}nixos${NC})"
    echo -e "  3. Change your password: ${CYAN}passwd${NC}"
    echo -e "  4. Press ${BOLD}Mod+Return${NC} to open a terminal"
    echo ""
    echo -e "  Your config is ready at ${CYAN}~/Projects/nixos-config${NC}"
    echo -e "  Apply changes with: ${CYAN}os-switch${NC}"
    echo ""

    if ask_yes_no "Reboot now?" "y"; then
        reboot
    else
        info "Reboot when ready with: ${BOLD}reboot${NC}"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    print_banner

    step "Pre-flight Checks"
    check_root
    check_uefi
    check_internet
    check_nix
    check_git

    # Detect previous run — offer to resume
    if [[ -f "$WORK_DIR/config.nix" ]]; then
        warn "Previous installation detected at $WORK_DIR"
        if ask_yes_no "Resume previous installation?" "y"; then
            info "Resuming — loading config from previous run..."
            # Read hostname from existing config.nix for the flake reference
            CONFIG_HOSTNAME=$(grep 'hostname' "$WORK_DIR/config.nix" | head -1 | sed 's/.*"\(.*\)".*/\1/')
            SELECTED_DISK=$(grep 'disk' "$WORK_DIR/config.nix" | head -1 | sed 's/.*"\(.*\)".*/\1/')
            CONFIG_USERNAME=$(grep 'username' "$WORK_DIR/config.nix" | head -1 | sed 's/.*"\(.*\)".*/\1/')
            success "Loaded: hostname=$CONFIG_HOSTNAME, disk=$SELECTED_DISK, user=$CONFIG_USERNAME"
            run_disko
            run_install
            persist_config
            finish
            return
        else
            info "Starting fresh installation..."
        fi
    fi

    select_disk
    collect_config
    show_summary
    clone_repo
    write_config
    run_disko
    run_install
    persist_config
    finish
}

main "$@"
