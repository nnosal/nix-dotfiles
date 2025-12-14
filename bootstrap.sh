#!/usr/bin/env bash

##############################################################################
# 🚀 NIX-DOTFILES BOOTSTRAP - SIMPLIFIED
# One-liner: curl https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.sh | bash
##############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️${NC}  $1"; }
log_ok() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠️${NC}  $1"; }
log_err() { echo -e "${RED}✗${NC}  $1" >&2; }

##############################################################################
# Phase 1: OS Detection
##############################################################################

log_info "Detecting platform..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
  SYSTEM="$(uname -m)-darwin"
elif [[ "$OSTYPE" == "linux"* ]]; then
  OS="linux"
  SYSTEM="$(uname -m)-linux"
else
  log_err "Unsupported OS: $OSTYPE"
  exit 1
fi

log_ok "System: $SYSTEM"

##############################################################################
# Phase 2: Install Nix if needed
##############################################################################

if ! command -v nix &> /dev/null; then
  log_warn "Installing Nix (unattended)..."
  if [ "$OS" = "darwin" ]; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  else
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm --init none
  fi
  log_ok "Nix installed"
else
  log_ok "Nix already installed"
fi

# Source Nix environment (try multiple paths)
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Verify nix works
if ! command -v nix &> /dev/null; then
  log_err "Nix not found in PATH. Please restart terminal and try again."
  exit 1
fi

log_ok "Nix ready: $(nix --version)"

##############################################################################
# Phase 3: Clone Repository
##############################################################################

log_info "Preparing to clone repository..."
echo ""

DEFAULT_PATH="$HOME/dotfiles"
echo "Where to clone the repository?"
echo "Default: $DEFAULT_PATH"
read -p "> " CLONE_PATH || CLONE_PATH=""
CLONE_PATH=${CLONE_PATH:-$DEFAULT_PATH}

# Check if path exists
if [ -d "$CLONE_PATH" ]; then
  log_warn "Directory already exists: $CLONE_PATH"
  read -p "Overwrite? (y/n) " -n 1 REPLY || REPLY=""
  echo ""
  if [ "$REPLY" != "y" ] && [ "$REPLY" != "Y" ]; then
    log_err "Cancelled"
    exit 0
  fi
  rm -rf "$CLONE_PATH"
fi

log_info "Cloning repository..."

# 🔥 FIX: Use direct variable expansion (NO heredoc, NO script file)
REPO_URL="https://github.com/nnosal/nix-dotfiles.git"

if command -v git &> /dev/null; then
  # Git already installed
  git clone "$REPO_URL" "$CLONE_PATH" || {
    log_err "Failed to clone repository"
    exit 1
  }
else
  # Use nix to provide git - export variables first
  export CLONE_PATH
  export REPO_URL
  nix-shell -p git --run 'git clone "$REPO_URL" "$CLONE_PATH"' || {
    log_err "Failed to clone repository"
    exit 1
  }
fi

log_ok "Repository cloned to: $CLONE_PATH"

##############################################################################
# Phase 4: Summary
##############################################################################

echo ""
echo -e "${GREEN}===================================================${NC}"
echo -e "${GREEN}✓${NC}  ${GREEN}Bootstrap completed!${NC} 🎉"
echo -e "${GREEN}===================================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Enter directory:"
echo -e "   ${YELLOW}cd ${CLONE_PATH}${NC}"
echo ""
echo "2. (Optional) Review configuration:"
echo -e "   ${YELLOW}cat ${CLONE_PATH}/flake.nix${NC}"
echo ""
echo "3. Apply system configuration:"
if [ "$OS" = "darwin" ]; then
  echo -e "   ${YELLOW}cd ${CLONE_PATH} && nix run nixpkgs#nh -- os switch --flake .${NC}"
else
  echo -e "   ${YELLOW}cd ${CLONE_PATH} && sudo nixos-rebuild switch --flake .${NC}"
fi
echo ""
echo "4. Apply user dotfiles:"
echo -e "   ${YELLOW}cd ${CLONE_PATH} && stow -S stow/common${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo -e "  - ${YELLOW}${CLONE_PATH}/README.md${NC} - Quick start"
echo -e "  - ${YELLOW}${CLONE_PATH}/docs/SETUP.md${NC} - Detailed guide"
echo -e "  - ${YELLOW}${CLONE_PATH}/docs/ARCHITECTURE.md${NC} - Design overview"
echo -e "  - ${YELLOW}${CLONE_PATH}/docs/SECRETS.md${NC} - Credential management"
echo -e "  - ${YELLOW}${CLONE_PATH}/docs/TROUBLESHOOTING.md${NC} - Common issues"
echo ""
