#!/usr/bin/env bash

##############################################################################
# 🚀 NIX-DOTFILES BOOTSTRAP
# One-liner entry point for zero-dependency setup
# Usage: curl https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.sh | bash
##############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️${NC}  $1"; }
log_ok() { echo -e "${GREEN}✓${NC}  $1"; }
log_warn() { echo -e "${YELLOW}⚠️${NC}  $1"; }
log_err() { echo -e "${RED}✗${NC}  $1" >&2; }

##############################################################################
# Phase 1: Détection de l'OS
##############################################################################

log_info "Detecting platform..."

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="darwin"
  ARCH=$(uname -m)
  if [[ "$ARCH" == "arm64" ]]; then
    SYSTEM="aarch64-darwin"
  else
    SYSTEM="x86_64-darwin"
  fi
elif [[ "$OSTYPE" == "linux"* ]]; then
  OS="linux"
  ARCH=$(uname -m)
  if [[ "$ARCH" == "aarch64" ]]; then
    SYSTEM="aarch64-linux"
  else
    SYSTEM="x86_64-linux"
  fi
else
  log_err "Unsupported OS: $OSTYPE"
  exit 1
fi

log_ok "System detected: $SYSTEM"

##############################################################################
# Phase 2: Vérifier/Installer Nix
##############################################################################

if ! command -v nix &> /dev/null; then
  log_warn "Nix not found. Installing..."
  if [ "$OS" = "darwin" ]; then
    # Installer Nix sur macOS
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  else
    # Installer Nix sur Linux
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --init none
  fi
  log_ok "Nix installed successfully"
else
  log_ok "Nix already installed"
fi

# Sourcer l'environnement Nix
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
  source ~/.nix-profile/etc/profile.d/nix.sh
fi

##############################################################################
# Phase 3: Clone le repo dans un shell éphémère avec Git + Gum
##############################################################################

log_info "Creating ephemeral shell with Git and Gum..."

nix shell nixpkgs#{git,gum} --command bash << 'EPHEMERAL_SHELL'
  set -euo pipefail
  
  # Réutiliser les fonctions de log
  log_info() { echo -e "${BLUE}ℹ️${NC}  $1"; }
  log_ok() { echo -e "${GREEN}✓${NC}  $1"; }
  log_warn() { echo -e "${YELLOW}⚠️${NC}  $1"; }
  
  # Demander le chemin de clone
  DEFAULT_PATH="$HOME/dotfiles"
  CLONE_PATH=$(gum input --placeholder "Clone directory" --value "$DEFAULT_PATH")
  CLONE_PATH=${CLONE_PATH:-$DEFAULT_PATH}
  
  if [ -d "$CLONE_PATH" ]; then
    log_warn "Directory already exists: $CLONE_PATH"
    if ! gum confirm "Overwrite?"; then
      log_err "Cancelled"
      exit 1
    fi
    rm -rf "$CLONE_PATH"
  fi
  
  log_info "Cloning repository..."
  git clone https://github.com/nnosal/nix-dotfiles.git "$CLONE_PATH"
  log_ok "Repository cloned to $CLONE_PATH"
  
  cd "$CLONE_PATH"
  
  # Lancer le setup interactif
  log_info "Starting interactive setup..."
  mise run bootstrap
  
EPHEMERAL_SHELL

log_ok "Bootstrap completed! 🎉"
log_info "Your dotfiles are ready at: $CLONE_PATH"
echo ""
echo "Next steps:"
echo "  cd $CLONE_PATH"
echo "  mise run ui"
echo ""
