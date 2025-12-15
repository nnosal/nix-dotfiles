#!/usr/bin/env bash
source ./scripts/utils.sh

# 1. Nettoyage des liens morts (sécurité)
stow --dir=stow --target=$HOME --delete common 2>/dev/null

# 2. Application du socle commun (Critique)
echo "🌍 Application du profil COMMON..."
stow --dir=stow --target=$HOME --restow common

# 3. Détection du Profil Machine (via variable ENV ou Gum)
# Cette variable peut être définie dans hosts/.../default.nix -> home.sessionVariables
PROFIL=${MACHINE_CONTEXT:-"$1"}

if [ -z "$PROFIL" ]; then
    # Si non défini, on demande (Interactif)
    if command -v gum >/dev/null; then
        PROFIL=$(gum choose "work" "personal" "none" --header "Quel profil Stow appliquer ?")
    else
        PROFIL="none"
    fi
fi

# 4. Application conditionnelle
if [ "$PROFIL" == "work" ]; then
    echo "💼 Application du profil WORK..."
    stow --dir=stow --target=$HOME --restow work
elif [ "$PROFIL" == "personal" ]; then
    echo "🏠 Application du profil PERSONAL..."
    stow --dir=stow --target=$HOME --restow personal
fi

echo "✅ Configuration déployée."
