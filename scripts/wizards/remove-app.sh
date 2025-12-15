#!/usr/bin/env bash
source ./scripts/utils.sh

# Wizard Remove App
# Crude implementation parsing common files

TYPE=$(gum choose "GUI App (Mac Cask)" "CLI Tool (Tous OS)")

if [ "$TYPE" == "GUI App (Mac Cask)" ]; then
    TARGET="modules/darwin/apps.nix"
    # Extract lines that look like strings
    APP=$(grep -oE '"[^"]+"' "$TARGET" | tr -d '"' | gum filter --placeholder "Select App to Remove")
    if [ -n "$APP" ]; then
        if [ "$(uname)" = "Darwin" ]; then
            sed -i '' "/\"$APP\"/d" "$TARGET"
        else
            sed -i "/\"$APP\"/d" "$TARGET"
        fi
    fi
else
    TARGET="modules/common/packages.nix"
    # Extract lines that look like pkgs.something
    APP=$(grep -oE 'pkgs\.[a-zA-Z0-9_-]+' "$TARGET" | gum filter --placeholder "Select Package to Remove")
    if [ -n "$APP" ]; then
        if [ "$(uname)" = "Darwin" ]; then
             sed -i '' "/$APP/d" "$TARGET"
        else
             sed -i "/$APP/d" "$TARGET"
        fi
    fi
fi

if [ -n "$APP" ]; then
    gum confirm "Removed $APP. Apply now?" && mise run switch
fi
