#!/usr/bin/env bash
source ./scripts/utils.sh

# 1. Choisir le type
TYPE=$(gum choose "GUI App (Mac Cask)" "CLI Tool (Tous OS)")
APP_NAME=$(gum input --placeholder "Nom du paquet (ex: vlc, ripgrep)")

if [ -z "$APP_NAME" ]; then exit 1; fi

if [ "$TYPE" == "GUI App (Mac Cask)" ]; then
    # Cible : modules/darwin/apps.nix
    TARGET="modules/darwin/apps.nix"
    MARKER="# %% CASKS %%"
    LINE="\"$APP_NAME\""
else
    # Cible : modules/common/packages.nix
    TARGET="modules/common/packages.nix"
    MARKER="# %% PACKAGES %%"
    LINE="pkgs.$APP_NAME"
fi

# 2. Injection (sed)
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "/$MARKER/a \\
    $LINE" "$TARGET"
else
    sed -i "/$MARKER/a \    $LINE" "$TARGET"
fi

gum style --foreground 212 "✅ $APP_NAME ajouté ! Lancement du switch..."
mise run switch
