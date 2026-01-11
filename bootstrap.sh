#!/usr/bin/env bash
set -e

# Ultimate Dotfiles Bootstrap
# Usage: sh <(curl -L https://dotfiles.nnosal.com)

REPO_URL="https://github.com/nnosal/nix-dotfiles.git"
TARGET_DIR="$HOME/dotfiles"

# 1. Zero-Install: Ensure Dependencies (Nix, Git, Gum)
if ! command -v nix >/dev/null; then
    echo "❄️  Installing Nix..."
    sudo sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Reload shell environment if Nix was just installed might be tricky in a script.
# We assume Nix is available or user restarts.
# But for "Ephemeral Shell", we usually rely on the user having Nix OR we use the Nix installer's environment.

if ! command -v git >/dev/null || ! command -v gum >/dev/null; then
    echo "📦 Entering Ephemeral Shell (Git + Gum)..."
    # Re-execute this script inside a nix shell with dependencies
    # We pass the current arguments to the nested script
    exec nix shell nixpkgs#git nixpkgs#gum -c bash "$0" "$@"
fi

# 2. Clone Repository
if [ ! -d "$TARGET_DIR" ]; then
    echo "📂 Cloning dotfiles to $TARGET_DIR..."
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "📂 Dotfiles already exist at $TARGET_DIR"
fi

cd "$TARGET_DIR"

# 3. Mode Detection (CI vs Interactive)
if [ "$CI" = "true" ]; then
    echo "🤖 CI Mode detected. Running non-interactive setup..."
    # Force apply without Gum interaction if possible, or use Gum in non-interactive way if supported (not really).
    # The Spec says: "./scripts/cockpit.sh --apply-only --profile $MACHINE_CONTEXT"

    ./scripts/cockpit.sh --apply-only --profile "${MACHINE_CONTEXT:-work}"
else
    # 4. Interactive Setup
    echo "🚀 Launching Cockpit..."
    ./scripts/cockpit.sh
fi
