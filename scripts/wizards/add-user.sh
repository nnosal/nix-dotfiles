#!/usr/bin/env bash
source ./scripts/utils.sh

USERNAME=$(gum input --placeholder "Username (ex: guest)")
[ -z "$USERNAME" ] && exit 1

FULLNAME=$(gum input --placeholder "Full Name")
EMAIL=$(gum input --placeholder "Email")

mkdir -p "users/$USERNAME"
cp "templates/user-profile.nix" "users/$USERNAME/default.nix"

if [ "$(uname)" = "Darwin" ]; then
    sed -i '' "s/%FULLNAME%/$FULLNAME/g" "users/$USERNAME/default.nix"
    sed -i '' "s/%EMAIL%/$EMAIL/g" "users/$USERNAME/default.nix"
else
    sed -i "s/%FULLNAME%/$FULLNAME/g" "users/$USERNAME/default.nix"
    sed -i "s/%EMAIL%/$EMAIL/g" "users/$USERNAME/default.nix"
fi

gum style --foreground 212 "User profile created at users/$USERNAME/default.nix"
gum style "Now import this user in your host configuration:"
echo "home-manager.users.$USERNAME = import ../../../users/$USERNAME/default.nix;"
