#!/usr/bin/env bash
source ./scripts/utils.sh

# Wizard pour ajouter un secret Fnox

KEY=$(gum input --placeholder "Nom de la variable (ex: STRIPE_KEY)")
[ -z "$KEY" ] && exit 1
VAL=$(gum input --password --placeholder "Valeur du secret")
[ -z "$VAL" ] && exit 1
NOTE=$(gum input --placeholder "Note pour le Keychain (optionnel)")

# Détection OS pour choisir le bon backend de stockage
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac: On écrit dans le Keychain via l'outil 'security' ou fnox directement
    if command -v fnox >/dev/null; then
        fnox set "$KEY" "$VAL"
    else
        security add-generic-password -a "$USER" -s "fnox-$KEY" -w "$VAL"
    fi
else
    # Linux: On utilise 'pass' ou le keyring system
    # Exemple avec 'pass' si fnox est configuré pour l'utiliser
    if command -v pass >/dev/null; then
        echo "$VAL" | pass insert -m "$KEY"
    else
        echo "Linux secret tool (pass) not found. Please install pass."
        exit 1
    fi
fi

# Update fnox.toml if not present
if ! grep -q "$KEY" fnox.toml; then
    echo "$KEY = \"keychain://$KEY\"" >> fnox.toml
fi

gum style --foreground 212 "🔒 Secret $KEY enregistré localement !"
gum style --foreground 240 "N'oublie pas de l'ajouter dans fnox.toml si ce n'est pas fait."
