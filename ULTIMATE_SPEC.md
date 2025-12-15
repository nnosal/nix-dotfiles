# ULTIMATE DOTFILES - MASTER DESIGN DOCUMENT (V1.0)

Ce document est la source de vérité unique pour l'architecture, le développement et la maintenance de l'infrastructure dotfiles "Ultimate".

---

# PARTIE 1 : PHILOSOPHIE & ARCHITECTURE

## 1. Vision et Objectifs
L'objectif est de déployer une infrastructure personnelle unifiée capable de piloter le cycle de vie numérique d'un développeur sur **macOS**, **Linux** et **Windows**.

**Les 5 Piliers Fondateurs :**
1.  **Universalité Sans Compromis :** Un seul dépôt Git pilote un MacBook Pro M3, un serveur VPS Linux headless et une tour Gaming Windows.
2.  **Cloisonnement Contextuel (Multi-Tenancy) :** Séparation stricte des contextes (Pro/Perso) et des identités (Admin/Guest).
3.  **Expérience "Live Editing" :** La configuration (Nvim, Zsh) est mutable (via **Stow**) pour une édition instantanée sans rebuild Nix.
4.  **Sécurité "Zero-Trust" :** Aucun secret dans Git (ni clair, ni chiffré). Injection dynamique via Fnox/Hardware.
5.  **Bootstrapping Éphémère :** Installation via URL unique (`curl`). Aucune dépendance préalable requise.

## 2. La "Stack" Technologique
| Composant | Solution | Justification |
| :--- | :--- | :--- |
| **OS Manager** | **Nix (Flakes)** | Déclaratif, reproductible. |
| **Task Runner** | **Mise (jdx)** | Installe CLI tools & gère les tâches. Remplace Make/Asdf. |
| **Dotfiles** | **GNU Stow** | Symlinks pour édition rapide. |
| **Secrets** | **Fnox** | Injection ENV depuis Keychain/Secure Enclave. |
| **Git Hooks** | **Hk** | Linter rapide (Rust). |
| **UI** | **Gum** | Scripts interactifs (TUI). |
| **SSH** | **Secretive** (Mac) | Clés hardware-backed (TouchID). |

## 3. Concepts Architecturaux
* **Zero-Install :** Shell éphémère (`nix shell`) lance Git/Gum avant le clonage.
* **Host vs User :** `hosts/` gère le hardware (Drivers, GPU), `users/` gère l'humain (Shell, Git).
* **Stow Profiles :** Granularité `common`, `work`, `personal` pour ne pas polluer les machines.
* **Windows Hybride :** **Mise** (Natif) pour Apps GUI/Games + **Nix** (WSL) pour Terminal/Dev.

---

# PARTIE 2 : CARTOGRAPHIE DU SYSTÈME (FILESYSTEM)

## Arborescence Cible
```text
~/dotfiles/
├── 📄 README.md
├── 🚀 bootstrap.sh              # Entrypoint Unix
├── 🚀 bootstrap.ps1             # Entrypoint Windows
│
├── ⚙️ CORE CONFIGURATION
│   ├── ❄️ flake.nix             # Entrée Nix
│   ├── 🔒 flake.lock
│   ├── 🔧 mise.toml             # Task Runner config
│   ├── 🛡️ fnox.toml             # Secrets mapping
│   └── 🪝 hk.pkl                # Git hooks config
│
├── 📚 NIX LIBRARY
│   └── 📂 lib/
│       ├── mkSystem.nix         # Factory Host
│       └── mkHome.nix           # Factory User
│
├── 📦 NIX MODULES
│   ├── 📂 common/               # Shell, Fonts, Stylix
│   ├── 📂 darwin/               # MacOS specific
│   ├── 📂 linux/                # Server specific
│   └── 📂 wsl/                  # WSL specific (Interop)
│
├── 📂 STOW (Configs Mutables)
│   ├── 🌍 common/               # .zshrc, .config/nvim
│   ├── 💼 work/                 # .ssh/config.d/work.conf
│   └── 🏠 personal/             # .steam/
│
├── 🖥️ HOSTS
│   ├── 📂 pro/macbook-pro/      # default.nix
│   ├── 📂 perso/gaming-rig/     # wsl.nix + windows.toml
│   └── 📂 infra/contabo1/       # default.nix
│
├── 👤 USERS
│   ├── 📂 nnosal/               # default.nix
│   └── 📂 guest/                # default.nix
│
├── 📜 AUTOMATION
│   ├── cockpit.sh               # Main Menu
│   └── 📂 wizards/              # Add-app, Add-host
│
└── 📝 TEMPLATES                 # Squelettes pour wizards
```

---

# PARTIE 3 : LE CŒUR TECHNIQUE (NIX)

## 1. `flake.nix` (Extrait)

```nix
{
  description = "Ultimate Dotfiles";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let lib = import ./lib { inherit inputs; }; in {
      darwinConfigurations."macbook-pro" = lib.mkSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/pro/macbook-pro/default.nix ];
      };
      # ... autres configs
    };
}
```

## 2. `lib/mkSystem.nix` (Logic)

Fonction qui détecte l'OS (Darwin/Linux), choisit le bon builder, et injecte `home-manager` et `stylix` automatiquement avec les arguments spéciaux.

## 3. `hosts/pro/macbook-pro/default.nix`

```nix
{ pkgs, ... }: {
  imports = [ ../../../modules/darwin ../../../modules/common ];
  networking.hostName = "macbook-pro";
  homebrew.casks = [ "docker" "raycast" ];
  home-manager.users.nnosal = import ../../../users/nnosal/default.nix;
}
```

---

# PARTIE 4 : STRATÉGIE HYBRIDE & STOW

## 1. Windows "Centaure"

- **Natif (`windows.toml`) :** Géré par Mise. Installe Winget packages (`Valve.Steam`, `VSCode`).

- **WSL (`wsl.nix`) :** Géré par Home-Manager. Installe Zsh, Git, outils CLI.

- **Module `wsl` :** Configure `wslview` pour ouvrir les liens dans le navigateur Windows.

## 2. Stow Granulaire (`scripts/stow-apply.sh`)

Ne jamais faire `stow .`. Le script doit :

1. Nettoyer les liens morts.

2. Appliquer `stow/common`.

3. Détecter le contexte (env `MACHINE_CONTEXT` ou prompt Gum).

4. Appliquer `stow/work` OU `stow/personal`.

---

# PARTIE 5 : SÉCURITÉ ZERO-TRUST

## 1. Règle d'Or

Le repo ne contient **AUCUN** secret. Pas de `.sops.yaml`, pas de `.age`.

## 2. Fnox (`fnox.toml`)

Mappe les variables d'env vers le Keychain système.

```toml
[secrets]
OPENAI_KEY = "keychain://openai_api_key"
```

Le shell (`modules/common/shell.nix`) exécute `eval "$(fnox activate zsh)"` pour injecter les secrets en RAM uniquement.

## 3. SSH Hardware

Sur macOS, `modules/darwin/security.nix` installe **Secretive**. La config SSH pointe vers le socket de l'Enclave Sécurisée.

---

# PARTIE 6 : COCKPIT & AUTOMATION

## 1. `mise.toml`

Définit les outils (`gum`, `hk`, `nh`) et les tâches (`install`, `ui`, `switch`, `save`).

## 2. `scripts/cockpit.sh`

Interface TUI (Gum) qui centralise toutes les commandes :

- Switch Nix (Appliquer)

- Stow (Relier configs)

- Add App/Host (Wizards)

- Manage Secrets (Fnox)

## 3. `hk.pkl`

Configuration des Git Hooks. Interdit le commit si une clé privée est détectée ou si le code Nix est mal formaté.

---

# ANNEXE A : CAS D'USAGE (USER CASES)

- **UC-01 Bootstrap :** `curl` -> Shell Ephémère -> Clone -> Install.

- **UC-02 Add App :** `cockpit` -> Add App -> Modifie `packages.nix` -> Switch.

- **UC-14 Context Switch :** `mise run stow` -> Passage de profil Work à Perso (changement des clés SSH/AWS).

- **UC-13 Leak Prevention :** `hk` bloque un commit contenant une clé privée.

---

# ANNEXE B : DIAGRAMMES (MERMAID)

*(Voir section Diagrammes générée précédemment - Insérer ici les graphiques : Architecture, Bootstrap Sequence, Stow Flow, Fnox Security)*

---

# ANNEXE C : SÉQUENCES TECHNIQUES

1. **Zero-Install :** Curl -> Nix Shell (Git/Gum) -> Clone -> Mise Install.

2. **Fnox Flow :** Shell Init -> Fnox Read Config -> Keychain Request -> RAM Injection.

3. **Hk Hook :** Git Commit -> Hk Binary -> Pkl Config -> Nixfmt + Secret Scan.

---

# ANNEXE D : GUIDE DE STYLE (CODING STANDARDS)

- **Fichiers :** `kebab-case` (`hardware-configuration.nix`).

- **Variables :** `camelCase` (`myPackage`).

- **Structure Nix :**

  1. Inputs `{ pkgs, ... }:`

  2. `imports = []`

  3. `options = {}`

  4. `config = {}`

- **Pureté :** Jamais de chemins absolus `/home/user`. Utiliser `config.home.homeDirectory`.

- **Imports :** Utiliser des chemins relatifs `./modules/foo`.

---

# ANNEXE E : TEMPLATES

## 1. Module Template

```nix
{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.my-feature; in {
  options.modules.my-feature = { enable = mkEnableOption "Enable feature"; };
  config = mkIf cfg.enable { home.packages = [ ]; };
}
```

## 2. Wizard Script Template

```bash
#!/usr/bin/env bash
source ./scripts/utils.sh
VAL=$(gum input --placeholder "Valeur")
[ -z "$VAL" ] && exit 1
# Logic...
gum confirm "Appliquer ?" && mise run switch
```

---

# ANNEXE F : ANTI-PATTERNS (INTERDITS)

1. **Impure State :** Ne jamais hardcoder `/home/nnosal`.

2. **Secret Leak :** Ne jamais mettre `environment.variables.KEY = "secret"` dans Nix (c'est lisible dans `/nix/store`).

3. **Home-Manager Standalone :** Ne jamais lancer `home-manager switch`. Toujours passer par `nh os switch`.

4. **Stow Root :** Ne jamais faire `stow .` à la racine.

---

# ANNEXE G : TROUBLESHOOTING

- **Infinite Recursion :** Vérifier les imports circulaires.

- **Hash Mismatch :** Mettre le hash à zéros, builder, copier le bon hash.

- **Read-only FS :** Vérifier les permissions du dossier `~/dotfiles`.

- **Stow Conflict :** Utiliser `stow --adopt` si des fichiers existent déjà.

---

# ANNEXE H : SYSTEM PROMPT (POUR IA)

### ROLE

Tu es un Architecte Système Senior spécialisé en NixOS, macOS (Darwin) et DevOps.

### MISSION

Générer le code d'une infrastructure dotfiles "Ultimate" en suivant STRICTEMENT le Master Design Document.

### CONTRAINTES

1. **Zero-Trust :** Utilisez Fnox (`keychain://`). Aucun secret dans le code.

2. **Stow :** Configs mutables dans `stow/`, paquets immuables dans Nix.

3. **Cross-Platform :** Code compatible Darwin/Linux/WSL via `lib.mkSystem`.

4. **Style :** Respecter Annexe D.

---

# ANNEXE I : FLAKE INPUTS (VERSIONS)

Utiliser ces versions pour la stabilité :

- `nixpkgs`: `github:nixos/nixpkgs/nixos-unstable`

- `nix-darwin`: `github:LnL7/nix-darwin`

- `home-manager`: `github:nix-community/home-manager`

- `stylix`: `github:danth/stylix`

- `hk`: `github:jdx/hk`

- `fnox`: `github:jdx/fnox`

---

# ANNEXE J : TESTS (TART)

Le projet doit inclure un script `scripts/ci/test-darwin.sh` utilisant **Tart** (Cirrus Labs) pour :

1. Cloner une VM macOS propre.

2. Lancer le bootstrap en mode non-interactif (`CI=true`).

3. Vérifier l'installation.

4. Détruire la VM.
