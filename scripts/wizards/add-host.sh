#!/usr/bin/env bash
source ./scripts/utils.sh

HOSTNAME=$(gum input --placeholder "Hostname (ex: dell-xps)")
[ -z "$HOSTNAME" ] && exit 1

TYPE=$(gum choose "NixOS" "Darwin")

if [ "$TYPE" == "NixOS" ]; then
    TEMPLATE="templates/host-nixos.nix"
    DEST_DIR="hosts/perso/$HOSTNAME"
    FLAKE_BLOCK="nixosConfigurations"
    SYSTEM_ARCH="x86_64-linux" # Default, could ask
else
    TEMPLATE="templates/host-darwin.nix"
    DEST_DIR="hosts/perso/$HOSTNAME"
    FLAKE_BLOCK="darwinConfigurations"
    SYSTEM_ARCH="aarch64-darwin"
fi

mkdir -p "$DEST_DIR"
cp "$TEMPLATE" "$DEST_DIR/default.nix"

# Replace Placeholder
if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/%HOSTNAME%/$HOSTNAME/g" "$DEST_DIR/default.nix"
else
    sed -i "s/%HOSTNAME%/$HOSTNAME/g" "$DEST_DIR/default.nix"
fi

# Inject into flake.nix (Very crude sed injection, usually dangerous but required by spec)
# We look for the block start and append
# This is tricky with sed. Ideally we tell user to add it manually or use a smarter tool.
# For this Wizard, we will print instruction if injection is too hard, OR try to append.

echo "
        \"$HOSTNAME\" = lib.mkSystem {
          system = \"$SYSTEM_ARCH\";
          modules = [ ./$DEST_DIR/default.nix ];
        };
" > /tmp/flake_injection.txt

gum style --foreground 212 "✨ Host created at $DEST_DIR/default.nix"
gum style "Copy/Paste this into flake.nix under $FLAKE_BLOCK:"
cat /tmp/flake_injection.txt
