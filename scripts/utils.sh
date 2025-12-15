#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Check if a command exists
has() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure we are inside the repo
ensure_repo_root() {
    if [ ! -f "flake.nix" ]; then
        error "Must be run from repository root"
        exit 1
    fi
}
