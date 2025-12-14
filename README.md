# 🔧 nix-dotfiles

**Dotfiles Universels Zero-to-Hero** : macOS, Linux, Windows (WSL)  
Stack : **Nix Flakes** + **Mise** + **GNU Stow** + **Fnox** (Secrets)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
![Platforms](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows%20(WSL)-blue)  
![Status](https://img.shields.io/badge/status-Active%20Development-green)

---

## 🚀 Quick Start

### Zero-Install Bootstrap (One-Liner)

```bash
# macOS / Linux
curl https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.ps1 | iex
```

The bootstrap script will:
1. ✅ Detect your OS (Darwin/Linux/Windows)
2. ✅ Install Nix (if not present)
3. ✅ Clone this repo with interactive path selection
4. ✅ Launch the setup wizard via **Gum**
5. ✅ Apply your config (Host + User profiles)

### Manual Setup

```bash
git clone https://github.com/nnosal/nix-dotfiles.git ~/dotfiles
cd ~/dotfiles
mise run bootstrap
```

---

## 📋 Architecture

### The "5 Pillars" Philosophy

1. **Universality Without Compromise** : Single repo for MacBook, VPS, Gaming PC
2. **Contextual Isolation** : Work vs Personal configs (Stow profiles)
3. **Live Editing** : Instant config changes (Stow + mutable dotfiles)
4. **Zero-Trust Repository** : No secrets in Git (Fnox + Keychain/Pass)
5. **Ephemeral Bootstrapping** : No pre-installed dependencies needed

### Directory Structure

```
nix-dotfiles/
├── flake.nix              # 🔷 Nix Flakes (packages, systems, configs)
├── mise.toml              # 🔧 Task runner (bootstrap, ui, switch, lint)
├── bootstrap.sh           # 🚀 One-liner entry point
├── bootstrap.ps1          # 🪟 Windows entry point
│
├── modules/               # 🧩 Reusable Nix configurations
│   ├── common/
│   │   ├── shell.nix      # Zsh + Starship + Fnox
│   │   ├── git.nix        # Git config
│   │   └── style.nix      # Theme (Stylix)
│   ├── darwin/            # 🍎 macOS specific
│   ├── linux/             # 🐧 Linux specific
│   └── wsl/               # 🪟 Windows WSL specific
│
├── hosts/                 # 🖥️ Machine configurations
│   ├── pro/               # Work machines
│   │   ├── macbook-pro/   # M3 MacBook
│   │   └── nixos-vps/     # Linux VPS
│   └── perso/             # Personal machines
│       └── gaming-rig/    # Windows + WSL
│
├── users/                 # 👤 User-specific configs
│   ├── nnosal/            # Main user
│   └── guest/             # Guest user (limited)
│
├── stow/                  # 📂 Dotfiles (via GNU Stow, live editable)
│   ├── common/            # Always applied
│   │   ├── .zshrc
│   │   ├── .config/zsh/
│   │   └── .config/nvim/
│   ├── work/              # Work-specific (pro machines)
│   │   ├── .ssh/config.d/work.conf
│   │   ├── .aws/
│   │   └── .config/git/work.conf
│   └── personal/          # Personal-specific
│       └── .config/games/
│
└── docs/                  # 📚 Documentation
    ├── ARCHITECTURE.md
    ├── SETUP.md
    ├── SECRETS.md
    └── TROUBLESHOOTING.md
```

---

## 🎯 Common Tasks

### Apply Configuration

```bash
# macOS
nh os switch --flake .

# Linux
sudo nixos-rebuild switch --flake .

# WSL (Home-Manager Standalone)
home-manager switch --flake .
```

### Edit Dotfiles (Live)

Files in `stow/` are symlinked directly—edit and save, no rebuild needed:

```bash
# Edit aliases (instant effect)
vim stow/common/.zshrc

# Source to reload
source ~/.zshrc
```

### Manage Secrets

Secrets are never stored in Git. They're injected at runtime via **Fnox**:

```bash
# Add a secret (stored in Keychain/Pass)
fnox set AWS_ACCESS_KEY_ID "my-key"

# Use in .zshenv or similar
export $(fnox list --export)

# Or directly in code
eval "$(fnox activate zsh)"
```

### Add a New Tool

1. **System-wide (Nix)** → Add to `flake.nix` or module
2. **User-specific (Home-Manager)** → Add to `users/nnosal/default.nix`
3. **Task runner** → Add to `mise.toml`
4. **Shell alias** → Edit `stow/common/.zshrc`

### Switch Profiles (Work vs Personal)

```bash
# Bootstrap will ask: "Which profile?"
# Apply only the configs you want:
stow -S stow/common     # Always
stow -S stow/work       # Work machines only
# OR
stow -S stow/personal   # Personal machines only
```

---

## 🛡️ Security Considerations

✅ **No Secrets in Git**
- All credentials stored in Keychain (macOS) or Pass (Linux)
- Injected at runtime via Fnox
- SSH keys in Secure Enclave (Secretive app)

✅ **Read-Only System**
- Nix immutability prevents unauthorized changes
- All config is version-controlled and reproducible

✅ **Secure Defaults**
- TouchID for `sudo` (macOS)
- SSH keys never on disk (hardware-backed)
- Environment variables cleared after session

---

## 📚 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** – Deep dive into design decisions
- **[SETUP.md](docs/SETUP.md)** – Step-by-step installation guide
- **[SECRETS.md](docs/SECRETS.md)** – How to manage credentials safely
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** – Common issues & solutions

---

## 🤝 Contributing

Feel free to fork and adapt for your own needs! This is a personal setup, but the patterns are generalizable.

### Development

```bash
# Lint Nix code
mise run lint

# Test (dry-run)
mise run test

# Format
statix check .
nixfmt **/*.nix
```

---

## 📝 License

MIT © [Nicolas Nosal](https://github.com/nnosal)

---

## 🙏 Acknowledgments

- [Nix Flakes](https://nixos.wiki/wiki/Flakes) for reproducibility
- [Nix-Darwin](https://github.com/lnl7/nix-darwin) for macOS support
- [Home-Manager](https://github.com/nix-community/home-manager) for user configs
- [GNU Stow](https://www.gnu.org/software/stow/) for dotfile linking
- [Fnox](https://github.com/jdx/fnox) for secret management
- [Mise](https://github.com/jdx/mise) for task running
- [Gum](https://github.com/charmbracelet/gum) for interactive scripts

---

**Questions?** Open an issue or check the docs! 🚀
