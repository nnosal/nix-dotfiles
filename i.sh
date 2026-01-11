
# Détection de l'OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="darwin"
    INSTALL_CMD="curl -L https://nixos.org/nix/install | sh"
    ACTIVATE_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
else
    OS="linux"
    INSTALL_CMD="curl -L https://nixos.org/nix/install | sh"
    ACTIVATE_SCRIPT="$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

echo "📍 OS détecté: $OS"
echo ""

# 1. Installer Nix (auto yes, thanks to no tty in "sh" mode) si absent
if ! command -v nix &> /dev/null; then
    echo "📦 Installation de Nix..."
    eval "$INSTALL_CMD"
    echo "✅ Nix installé"
    echo "$ACTIVATE_SCRIPT"
    if [ -e "$ACTIVATE_SCRIPT" ]; then
        source $ACTIVATE_SCRIPT
        if ! command -v nix &> /dev/null; then
            echo "❌ Erreur: Nix n'est pas disponible après sourcing"
            echo "    Essayer de redémarrer la session shell"
            exit 1
        fi
        echo "✅ Nix est activé"
        nix flake || (mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf && echo "✅ Nix Flake (experimental) est maintenant activé")
        #sudo nix flake || (sudo mkdir -p /etc/nix && echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf && sudo launchctl kickstart -k system/org.nixos.nix-daemon && echo "✅ SUDO Nix Flake (experimental) est maintenant activé" && sudo nix flake)
        echo ""
    else
        echo "⚠️  Profile Nix non trouvé. Vérifier l'installation."
        exit 1
    fi
else
    echo "✅ Nix déjà installé"
fi

nix-env -iA nixpkgs.nh
nh --version

nix-env -iA nixpkgs.mise
mise --version