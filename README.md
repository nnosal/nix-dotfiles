# 🚀 Ultimate Dotfiles

> **Universal Infrastructure for macOS, Linux & Windows.**
> Powered by [Nix](https://nixos.org), [Mise](https://mise.jdx.dev), [Stow](https://www.gnu.org/software/stow/), and [Fnox](https://github.com/jdx/fnox).

[![CI](https://github.com/nnosal/nix-dotfiles2/actions/workflows/ci.yml/badge.svg)](https://github.com/nnosal/nix-dotfiles2/actions)

## ⚡️ Quick Start (Zero-Install)

No git clone required. Just run this:

### 🍎 macOS / 🐧 Linux
```bash
sh <(curl -L https://raw.githubusercontent.com/nnosal/nix-dotfiles2/refs/heads/jules-ultimate-dotfiles-init-11317754922896183441/bootstrap.sh)
```

### 🪟 Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/nnosal/nix-dotfiles2/refs/heads/jules-ultimate-dotfiles-init-11317754922896183441/bootstrap.ps1 | iex
```

---

## 🏗 Architecture

This repository is designed with a **Zero-Trust** and **Multi-Tenant** philosophy.

-   **❄️ Nix Flakes**: Manages the OS state (packages, services, system settings).
-   **🔗 GNU Stow**: Manages mutable config files (`.zshrc`, `.config/nvim`) via symlinks.
-   **🛡️ Fnox**: Injects secrets into the shell from the system Keychain (Zero-Trust).
-   **🎛️ Cockpit**: A TUI dashboard (`./scripts/cockpit.sh`) to manage the system.

### Directory Structure

```text
~/dotfiles/
├── 📄 README.md                 # This file
├── 🚀 bootstrap.sh              # Entrypoint (Mac/Linux)
├── 🚀 bootstrap.ps1             # Entrypoint (Windows)
│
├── ⚙️ CORE CONFIGURATION
│   ├── ❄️ flake.nix             # Nix Flake Definitions (Inputs/Outputs)
│   ├── 🔧 mise.toml             # Task Runner config (Tools & Tasks)
│   ├── 🛡️ fnox.toml             # Secrets mapping (Zero-Trust)
│   └── 🪝 hk.pkl                # Git hooks config (Linting)
│
├── 📦 NIX MODULES
│   ├── 📂 common/               # Shared Configs (Shell, Fonts, Stylix)
│   ├── 📂 darwin/               # MacOS specific
│   ├── 📂 linux/                # Server specific
│   └── 📂 wsl/                  # WSL specific (Interop)
│
├── 📂 STOW (Mutable Configs)
│   ├── 🌍 common/               # Applied everywhere (.zshrc, nvim)
│   ├── 💼 work/                 # Applied on Work machines (.ssh/work.conf)
│   └── 🏠 personal/             # Applied on Personal machines (.steam/)
│
├── 🖥️ HOSTS
│   ├── 📂 pro/macbook-pro/      # Host definition (Darwin)
│   ├── 📂 perso/gaming-rig/     # Host definition (WSL + Windows)
│   └── 📂 infra/contabo1/       # Host definition (NixOS)
│
└── 📜 AUTOMATION
    ├── cockpit.sh               # Main Menu
    └── 📂 wizards/              # Helper scripts
```

---

## 🎮 The Cockpit

Once installed, manage everything via the Cockpit TUI:

```bash
mise run ui
# or simply
./scripts/cockpit.sh
```

### Key Commands

| Command | Description |
| :--- | :--- |
| `mise run install` | Initial bootstrap (Install hooks, Apply Nix) |
| `mise run switch` | **Rebuild Nix System** (Apply changes) |
| `mise run stow` | **Refresh Symlinks** (Apply mutable configs) |
| `mise run save` | **Git Push** (Add + Commit + Push with checks) |
| `mise run gc` | **Garbage Collect** (Free up disk space) |

---

## 🔐 Secrets (Zero-Trust)

We **NEVER** store secrets in Git (not even encrypted).
Secrets are stored in your **System Keychain** (TouchID / Gnome Keyring) and mapped via `fnox.toml`.

To add a secret interactively:
```bash
./scripts/wizards/secret.sh
```

---

## 🪟 Windows "Centaur" Strategy

On Windows, we use a hybrid approach:
-   **Native (Mise + Winget)**: Installs GUI apps (Steam, Discord, VSCode).
-   **WSL (Nix)**: Provides the robust Zsh/Linux dev environment.

Run `bootstrap.ps1` to setup the Native side, then enter WSL to setup the Linux side.

---

## 🛠️ Troubleshooting

See [ULTIMATE_SPEC.md](ULTIMATE_SPEC.md) for detailed architecture, sequence diagrams, and troubleshooting guide.
