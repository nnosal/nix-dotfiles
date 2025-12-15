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
        nh os switch .
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

# Main Menu Loop (Spec Part 6)
while true; do
    clear
    gum style --border double --margin "1" --padding "1 2" --border-foreground 212 "🎛️  ULTIMATE COCKPIT"

    CHOICE=$(gum choose \
        "🔄 Appliquer (Switch Nix)" \
        "🔗 Relier Dotfiles (Stow)" \
        "✨ Ajouter (App/Host/User)" \
        "✏️  Éditer une config (Fuzzy)" \
        "🔒 Gérer Secrets (Fnox)" \
        "🚀 Sauvegarder (Git Push)" \
        "🧹 Nettoyer (Garbage Collect)" \
        "🗑️  Désinstaller une App" \
        "🚪 Quitter")

    case "$CHOICE" in
        "🔄 Appliquer"*)
            mise run switch
            gum confirm "Done! Press Enter to continue" && continue
            ;;
        "🔗 Relier"*)
             mise run stow
             gum confirm "Done! Press Enter to continue" && continue
            ;;
        "✨ Ajouter"*)
            SUB=$(gum choose "Application (Cask/Pkg)" "Machine (Host)" "Utilisateur")
            case $SUB in
                "Application"*) ./scripts/wizards/add-app.sh ;;
                "Machine"*)     ./scripts/wizards/add-host.sh ;;
                "Utilisateur"*) ./scripts/wizards/add-user.sh ;;
            esac
            ;;
        "✏️  Éditer"*)      ./scripts/wizards/edit.sh ;;
        "🔒 Gérer"*)       ./scripts/wizards/secret.sh ;;
        "🚀 Sauvegarder"*)  mise run save ;;
        "🧹 Nettoyer"*)     mise run gc ;;
        "🗑️  Désinstaller"*) ./scripts/wizards/remove-app.sh ;;
        "🚪 Quitter")      exit 0 ;;
    esac
done
