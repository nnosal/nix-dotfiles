#!/usr/bin/env bash
source ./scripts/utils.sh

# Cockpit - The Main Menu
# Usage: ./cockpit.sh [--apply-only] [--profile NAME]

APPLY_ONLY=false
PROFILE=""

# Parse Args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --apply-only) APPLY_ONLY=true ;;
        --profile) PROFILE="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# If Apply Only, skip menu
if [ "$APPLY_ONLY" = "true" ]; then
    info "Applying configuration..."
    # 1. Stow
    ./scripts/stow-apply.sh "$PROFILE"

    # 2. Nix Switch (using nh if available, else nix)
    if command -v nh >/dev/null; then
        nh os switch
    else
        # Fallback detection
        if [ "$(uname)" = "Darwin" ]; then
            nix run nix-darwin -- switch --flake .
        else
            sudo nixos-rebuild switch --flake .
        fi
    fi
    exit 0
fi

# Main Menu Loop
while true; do
    clear
    gum style --border normal --margin "1" --padding "1 2" --border-foreground 212 "🚀 ULTIMATE DOTFILES COCKPIT"

    CHOICE=$(gum choose \
        "🔄 Apply Configuration (Switch)" \
        "🔗 Manage Symlinks (Stow)" \
        "✨ Add New App (Wizard)" \
        "🖥️  Add New Host (Wizard)" \
        "🔒 Manage Secrets (Fnox)" \
        "👋 Exit")

    case "$CHOICE" in
        "🔄 Apply Configuration (Switch)")
            gum spin --spinner dot --title "Switching..." -- ./scripts/cockpit.sh --apply-only
            gum confirm "Done! Press Enter to continue" && continue
            ;;
        "🔗 Manage Symlinks (Stow)")
             ./scripts/stow-apply.sh
             gum confirm "Done! Press Enter to continue" && continue
            ;;
        "✨ Add New App (Wizard)")
            gum style --foreground 212 "TODO: Add App Wizard"
            sleep 1
            ;;
        "🔒 Manage Secrets (Fnox)")
            # Interactive Fnox
            KEY=$(gum input --placeholder "Secret Name (e.g. STRIPE_KEY)")
            [ -z "$KEY" ] && continue
            VAL=$(gum input --password --placeholder "Secret Value")
            [ -z "$VAL" ] && continue

            # Use system specific tool to add to keychain
            if [ "$(uname)" = "Darwin" ]; then
                security add-generic-password -a "$USER" -s "$KEY" -w "$VAL"
            else
                echo "Linux secret tool not implemented in this skeleton yet"
            fi

            # Update fnox.toml
            if ! grep -q "$KEY" fnox.toml; then
                echo "$KEY = \"keychain://$KEY\"" >> fnox.toml
            fi
            gum style --foreground 212 "Secret added to Keychain and fnox.toml mapped!"
            sleep 2
            ;;
        "👋 Exit")
            exit 0
            ;;
    esac
done
