#!/usr/bin/env bash
set -euo pipefail

# Debian/Ubuntu bootstrap script
# Run as a normal user (it will sudo as needed).
# This script is idempotent and safe to re-run.

# Color codes
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

# Configuration
CHINA_MIRRORS=true  # Set to false to use default mirrors
LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/debian-setup-$(date +%s).log"

# Create log directory
mkdir -p "$(dirname "$LOG_FILE")"

#############################################################################
# Utility Functions
#############################################################################

log() {
    local level="$1"
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "$LOG_FILE"
}

error() {
    printf "${RED}ERROR: %s${NC}\n" "$@" | tee -a "$LOG_FILE"
}

success() {
    printf "${GREEN}✓ %s${NC}\n" "$@" | tee -a "$LOG_FILE"
}

warning() {
    printf "${YELLOW}⚠ %s${NC}\n" "$@" | tee -a "$LOG_FILE"
}

step() {
    printf "\n${GREEN}[Step] %s${NC}\n" "$@" | tee -a "$LOG_FILE"
}

die() {
    error "$@"
    exit 1
}

# Download a file with error handling
download_file() {
    local url="$1"
    local dest="$2"
    local description="${3:-file}"
    
    log "INFO" "Downloading $description from $url"
    if ! curl -fLo "$dest" --create-dirs "$url" 2>>"$LOG_FILE"; then
        die "Failed to download $description from $url"
    fi
    success "Downloaded $description"
}

# Clone a git repository with idempotency
clone_if_missing() {
    local url="$1"
    local dest="$2"
    local description="${3:-repository}"
    
    if [ -d "$dest" ]; then
        log "INFO" "$description already exists at $dest, skipping"
    else
        log "INFO" "Cloning $description from $url"
        if ! git clone "$url" "$dest" 2>>"$LOG_FILE"; then
            die "Failed to clone $description from $url"
        fi
        success "Cloned $description"
    fi
}

# Check if command exists
require_command() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        die "Required command '$cmd' not found"
    fi
}

# Confirm user action
confirm() {
    local prompt="$1"
    local response
    
    printf "${RED}%s${NC} [y/N]: " "$prompt" >&2
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Create timestamped backup (with sudo if needed for system files)
backup_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return
    fi
    
    local backup="${file}.bak.$(date +%s)"
    
    # System files under /etc typically need sudo
    if [[ "$file" == /etc/* ]]; then
        sudo cp "$file" "$backup"
    else
        cp "$file" "$backup"
    fi
    log "INFO" "Backed up $file to $backup"
}

#############################################################################
# Pre-flight Checks
#############################################################################

step "Running pre-flight checks"

require_command sudo
require_command curl

# Check internet connectivity
if ! curl -s --connect-timeout 2 https://www.baidu.com >/dev/null 2>&1; then
    warning "Internet connectivity may be limited"
fi

# Check disk space (require at least 500MB)
available_space=$(df "$HOME" | tail -1 | awk '{print $4}')
if [ "$available_space" -lt 512000 ]; then
    die "Insufficient disk space in $HOME (need 500MB)"
fi

success "Pre-flight checks passed"

#############################################################################
# User Confirmation
#############################################################################

cat << 'EOF'

⚠️  WARNING: This script is only suitable for fresh Debian system(>=12).
    1. It may overwrite configuration files such as:
        - init.vim
        - ~/.zshrc
        - ~/.alias
        - ~/.oh-my-zsh/
    2.  'stable' is used in apt sources which may trigger major upgrades(e.g. from Debian 12 to 13).

EOF

if ! confirm "Are you sure you want to proceed?"; then
    log "INFO" "User aborted setup"
    exit 0
fi

success "Proceeding with setup"

#############################################################################
# Configure Package Manager
#############################################################################

step "Configuring package manager"

# Backup original sources
backup_file /etc/apt/sources.list

if [ "$CHINA_MIRRORS" = true ]; then
    log "INFO" "Configuring for China mirrors (Gitee)"
    download_file \
        "https://gitee.com/huntermg/dotfiles/raw/main/apt/debian-cn.sources" \
        "/tmp/debian.sources" \
        "debian.sources"
    sudo cp /tmp/debian.sources /etc/apt/sources.list.d/debian.sources
    
    download_file \
        "https://gitee.com/huntermg/dotfiles/raw/main/apt/debian-backports-cn.sources" \
        "/tmp/debian-backports.sources" \
        "debian-backports.sources"
    sudo cp /tmp/debian-backports.sources /etc/apt/sources.list.d/debian-backports.sources
    
    # Disable default sources.list to avoid conflicts
    if [ -f /etc/apt/sources.list ]; then
        sudo mv /etc/apt/sources.list /etc/apt/sources.list.disabled
    fi
    success "Configured for China mirrors"
else
    log "INFO" "Using default package mirrors"
fi

step "Updating package lists"
if ! sudo apt-get update 2>>"$LOG_FILE"; then
    die "Failed to update package lists"
fi
success "Package lists updated"

log "INFO" "Upgrading existing packages"
APT_OPTS=(
  -y
  -o Dpkg::Options::="--force-confdef"
  -o Dpkg::Options::="--force-confold"
)

apt_noninteractive() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get "${APT_OPTS[@]}" "$@"
}

if ! apt_noninteractive upgrade 2>>"$LOG_FILE"; then
    die "Failed to upgrade packages"
fi
success "Packages upgraded"

#############################################################################
# Install System Packages
#############################################################################

step "Installing system packages"

sudo apt-get install -y \
    git \
    curl \
    wget \
    tmux \
    zsh \
    lua5.2 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    pipx \
    neovim 2>>"$LOG_FILE" || die "Failed to install system packages"

log "INFO" "Removing unnecessary packages"
sudo apt-get autoremove -y 2>>"$LOG_FILE"

success "System packages installed"

#############################################################################
# Configure Python Package Manager
#############################################################################

step "Configuring Python package manager"

log "INFO" "Setting pip index to Tsinghua mirror"
pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

log "INFO" "Installing pipx tools"
export UV_DEFAULT_INDEX="https://pypi.tuna.tsinghua.edu.cn/simple"

pipx install uv 2>>"$LOG_FILE" || warning "pipx install uv may have failed"
## add uv to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Install thefuck with Python 3.11
log "INFO" "Installing thefuck with UV"
if ! UV_PYTHON=3.11 uv tool install thefuck 2>>"$LOG_FILE"; then
    warning "Failed to install thefuck; attempting with default Python"
    pipx install thefuck 2>>"$LOG_FILE" || warning "thefuck installation failed"
fi

success "Python tools configured"

#############################################################################
# Setup Neovim
#############################################################################

step "Setting up Neovim"

# Install vim-plug plugin manager
log "INFO" "Installing vim-plug"
download_file \
    "https://gitee.com/huntermg/vim-plug/raw/master/plug.vim" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" \
    "vim-plug"

# Download init.vim configuration
log "INFO" "Installing Neovim configuration"
download_file \
    "https://gitee.com/huntermg/dotfiles/raw/main/init.vim" \
    "$HOME/.config/nvim/init.vim" \
    "Neovim init.vim"

success "Neovim configured"

#############################################################################
# Setup Oh My Zsh
#############################################################################

step "Setting up Oh My Zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
    log "INFO" "Oh My Zsh already installed, skipping installation"
else
    log "INFO" "Installing Oh My Zsh"
    export REMOTE="https://gitee.com/mirrors/oh-my-zsh.git"
    if ! sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" "" --unattended 2>>"$LOG_FILE"; then
        die "Failed to install Oh My Zsh"
    fi
    success "Oh My Zsh installed"
fi

# Backup and download .zshrc
log "INFO" "Installing Zsh configuration"
backup_file "$HOME/.zshrc"
download_file \
    "https://gitee.com/huntermg/dotfiles/raw/main/.zshrc" \
    "$HOME/.zshrc" \
    ".zshrc configuration"

# Download .alias
log "INFO" "Installing Zsh aliases"
download_file \
    "https://gitee.com/huntermg/dotfiles/raw/main/.alias" \
    "$HOME/.alias" \
    ".alias configuration"

success "Zsh configurations installed"

#############################################################################
# Install Zsh Plugins
#############################################################################

step "Installing Zsh plugins"

zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Create plugins directory if it doesn't exist
mkdir -p "$zsh_custom/plugins"

clone_if_missing \
    "https://gitee.com/mirrors/zsh-autosuggestions.git" \
    "$zsh_custom/plugins/zsh-autosuggestions" \
    "zsh-autosuggestions"

clone_if_missing \
    "https://gitee.com/mirrors/zsh-syntax-highlighting.git" \
    "$zsh_custom/plugins/zsh-syntax-highlighting" \
    "zsh-syntax-highlighting"

# Ensure git directory exists
mkdir -p "$HOME/git"

clone_if_missing \
    "https://gitee.com/mirrors/z.lua.git" \
    "$HOME/git/z.lua" \
    "z.lua"

success "Zsh plugins installed"

#############################################################################
# Completion
#############################################################################

step "Setup complete!"

printf "%b\n" "

${GREEN}✓ Setup completed successfully!${NC}

Next steps:
1. Review the log file: $LOG_FILE
2. Re-login or restart your terminal to apply all changes.
3. Run 'nvim +PlugInstall' to install Neovim plugins.
4. Verify zsh plugins are loaded: zsh_stats.
5. Bring your network back if it was down.
6. Run 'chsh -s \$(command -v zsh)' to set zsh as default shell (may require logout/login).
7. Run 'sudo apt full-upgrade' to ensure all packages are up to date.

Configuration backed up:
- /etc/apt/sources.list → /etc/apt/sources.list.bak.*
- ~/.zshrc → ~/.zshrc.bak.*

"

success "Log file: $LOG_FILE"
