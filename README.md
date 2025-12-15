# 🚀 Ultimate Dotfiles

> **Universal Infrastructure for macOS, Linux & Windows.**
> Powered by [Nix](https://nixos.org), [Mise](https://mise.jdx.dev), [Stow](https://www.gnu.org/software/stow/), and [Fnox](https://github.com/jdx/fnox).

[![CI](https://github.com/nnosal/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/nnosal/dotfiles/actions)

## ⚡️ Quick Start (Zero-Install)

No git clone required. Just run this:

### 🍎 macOS / 🐧 Linux
```bash
sh <(curl -L https://dotfiles.nnosal.com)
```

### 🪟 Windows (PowerShell)
```powershell
irm https://dotfiles.nnosal.com/win | iex
```

---

## 🏗 Architecture

This repository is designed with a **Zero-Trust** and **Multi-Tenant** philosophy.

-   **❄️ Nix Flakes**: Manages the OS state (packages, services, system settings).
-   **🔗 GNU Stow**: Manages mutable config files (`.zshrc`, `.config/nvim`) via symlinks.
-   **🛡️ Fnox**: Injects secrets into the shell from the system Keychain (Zero-Trust).
-   **🎛️ Cockpit**: A TUI dashboard (`./scripts/cockpit.sh`) to manage the system.

### Directory Structure

-   `hosts/`: Hardware definitions (MacBook, VPS, Gaming PC).
-   `users/`: User profiles (Dev tools, Shell config).
-   `modules/`: Reusable Nix modules (Darwin, Linux, WSL).
-   `stow/`: Mutable dotfiles (Zsh, Neovim) organized by profile (`common`, `work`, `personal`).

---

## 🎮 The Cockpit

Once installed, manage everything via the Cockpit TUI:

```bash
mise run ui
# or simply
./scripts/cockpit.sh
```

**Common Tasks:**
-   **Apply Config**: `mise run switch` (Rebuilds Nix)
-   **Manage Symlinks**: `mise run stow` (Links dotfiles)
-   **Add App**: `cockpit` -> "Add App"
-   **Secrets**: `cockpit` -> "Manage Secrets"

---

## 🔐 Secrets (Zero-Trust)

We **NEVER** store secrets in Git (not even encrypted).
Secrets are stored in your **System Keychain** (TouchID / Gnome Keyring) and mapped via `fnox.toml`.

To add a secret:
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

See [ULTIMATE_SPEC.md](ULTIMATE_SPEC.md) for detailed architecture and troubleshooting guide.
