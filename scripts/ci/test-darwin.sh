#!/usr/bin/env bash
set -e
source ./scripts/utils.sh

VM_NAME="test-dotfiles-$(date +%s)"
IMAGE="ghcr.io/cirruslabs/macos-sonoma-base:latest"

gum style --foreground 212 "🧪 Démarrage du test d'intégration macOS (Tart)..."

# 1. Création de la VM
echo "📦 Clonage de l'image $IMAGE..."
tart clone "$IMAGE" "$VM_NAME"

# Fonction de nettoyage (trap) pour toujours supprimer la VM à la fin
cleanup() {
    echo "🧹 Nettoyage de la VM..."
    tart stop "$VM_NAME" || true
    tart delete "$VM_NAME" || true
}
trap cleanup EXIT

# 2. Démarrage
echo "🚀 Boot de la VM..."
tart run "$VM_NAME" --no-graphics &
PID=$!

# 3. Attente de l'IP (Polling)
echo "⏳ Attente de la connectivité réseau..."
IP=""
for i in {1..30}; do
    IP=$(tart ip "$VM_NAME" 2>/dev/null || true)
    if [ -n "$IP" ]; then break; fi
    sleep 2
done

if [ -z "$IP" ]; then
    echo "❌ Impossible de récupérer l'IP de la VM."
    exit 1
fi

echo "✅ VM en ligne sur $IP. Attente du service SSH..."
# On attend que le port 22 soit ouvert
while ! nc -z "$IP" 22; do sleep 1; done

# 4. Exécution du Bootstrap (Mode CI)
# Note : Les images Cirrus ont user=admin, pass=admin
echo "🛠️  Lancement du Bootstrap..."

# On injecte une variable d'env CI=true pour que le bootstrap
# passe en mode non-interactif
sshpass -p "admin" ssh -o StrictHostKeyChecking=no admin@"$IP" \
    "export CI=true && export MACHINE_CONTEXT=work && sh <(curl -L https://dotfiles.nnosal.com)"

# 5. Vérification
echo "🔍 Vérification de l'installation..."
sshpass -p "admin" ssh -o StrictHostKeyChecking=no admin@"$IP" \
    "command -v nix && command -v zsh && [ -f ~/.zshrc ]"

gum style --foreground 46 "✅ TEST RÉUSSI : La configuration s'installe et boot correctement !"
