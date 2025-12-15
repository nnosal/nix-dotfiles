#!/usr/bin/env bash
source ./scripts/utils.sh

# Liste tous les fichiers .nix, .toml, .lua en ignorant le dossier .git et result
FILE=$(find . -type f \( -name "*.nix" -o -name "*.toml" -o -name "*.lua" \) \
    -not -path "*/.git/*" -not -path "*/result/*" | \
    gum filter --placeholder "🔍 Quel fichier modifier ?")

# Ouvre avec l'éditeur par défaut ($EDITOR ou vim)
if [ -n "$FILE" ]; then
    ${EDITOR:-vim} "$FILE"

    # Propose d'appliquer après fermeture
    if gum confirm "Voulez-vous appliquer les changements maintenant ?"; then
        # Détecte si c'est un fichier Stow (dans stow/) ou Nix
        if [[ "$FILE" == *"stow/"* ]]; then
            mise run stow
        else
            mise run switch
        fi
    fi
fi
