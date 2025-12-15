#!/usr/bin/env bash
set -e

# verify_linux.sh
# Verifies the NixOS configuration using a test target.

# Source Nix
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
elif [ -f "/etc/profile.d/nix.sh" ]; then
    . "/etc/profile.d/nix.sh"
fi

# Enable Flakes
export NIX_CONFIG="experimental-features = nix-command flakes"

echo "❄️ Verifying Flake..."

# 1. Check Flake Metadata
nix flake metadata

# 2. Evaluate the Test Linux System Configuration
echo "🐧 Evaluating NixOS Configuration (test-linux)..."
# We instantiate the system to ensure the modules resolve correctly.
# This target includes the dummy hardware config.
nix eval .#nixosConfigurations.test-linux.config.system.build.toplevel.drvPath

echo "✅ Linux Verification Passed!"
