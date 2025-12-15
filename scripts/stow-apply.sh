#!/usr/bin/env bash
source ./scripts/utils.sh

# Stow Manager
# Usage: ./stow-apply.sh [profile_name]

TARGET_PROFILE="$1"

# If no profile provided, ask via Gum
if [ -z "$TARGET_PROFILE" ] && command -v gum >/dev/null; then
    TARGET_PROFILE=$(gum choose "work" "personal" "none")
fi

if [ -z "$TARGET_PROFILE" ]; then
    TARGET_PROFILE="personal" # Default
fi

info "Applying Stow Configurations..."

# 1. Clean dead links (safety)
# stow -D ... (simplified here)

# 2. Apply Common
info "Linking Common..."
stow --dir stow --target "$HOME" --restow common

# 3. Apply Context
if [ "$TARGET_PROFILE" != "none" ]; then
    info "Linking Profile: $TARGET_PROFILE..."
    stow --dir stow --target "$HOME" --restow "$TARGET_PROFILE"
fi

success "Stow complete!"
