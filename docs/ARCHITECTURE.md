# 💫 Architecture Overview

This document explains the foundational design of **nix-dotfiles** and the rationale behind each component.

## The "5 Pillars" Design Philosophy

### 1. Universality Without Compromise

**Goal:** One repository manages infrastructure across completely different machines:
- 🍎 macOS (M3 MacBook Pro)
- 🐧 Linux (NixOS VPS, Ubuntu desktop)
- 🪟 Windows (Native + WSL)

**Implementation:**
- **Nix Flakes** for declarative, reproducible system configs
- **Conditional logic** in `flake.nix` to load Darwin/NixOS/WSL configs
- **Host + User separation** so one person can use multiple machines

### 2. Contextual Isolation (Multi-Tenancy)

**Goal:** Prevent "work bleeding into personal" and vice versa.

**Scenarios:**
- AWS credentials should only be on work MacBook, not personal PC
- Gaming configs stay on gaming rig, not on VPS
- Guest account has limited access

**Implementation:**
- **Stow Profiles:** `stow/common` (always), `stow/work` (work machines), `stow/personal` (personal)
- **Host + User matrices:** Which user on which host gets which profile?
- **Fnox secrets per profile:** Work secrets =/= personal secrets

### 3. Live Editing Without Rebuilds

**Goal:** Edit shell aliases, Nvim config, Git settings instantly without:
- Waiting for Nix rebuild (slow for large configs)
- Dealing with read-only file systems
- Managing complex derivations

**Implementation:**
- **GNU Stow** symlinks dotfiles from `stow/` to `$HOME`
- **Stow files are mutable:** Edit `.zshrc`, source it, done
- **Nix manages immutable system state** (packages, drivers)
- **Clean separation of concerns:** Nix = system, Stow = user config

**Example:**
```bash
# Edit immediately effective
vim stow/common/.zshrc
source ~/.zshrc  # Instant reload

# Nix rebuild NOT needed
```

### 4. Zero-Trust Repository

**Goal:** Repository can be public. Secrets never in Git (even encrypted).

**Why?**
- Encrypted secrets can be decrypted if key is compromised
- Reduces attack surface
- Simpler to audit

**Implementation:**
- **Fnox** injects secrets from Keychain (macOS) or Pass (Linux) at runtime
- **Secretive** keeps SSH keys in hardware Secure Enclave
- **Environment variables** populated on shell init, never persisted
- **No `.env` files in repo**

**Example:**
```nix
# In shell.nix, NEVER hardcode secrets:
initExtra = ''
  eval "$(fnox activate zsh)"  # Load from Keychain
'';

# Not:
# export AWS_KEY="sk-xyz..."  # NEVER!
```

### 5. Ephemeral Bootstrapping

**Goal:** Zero installation friction. One command:
```bash
curl https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.sh | bash
```

**Pre-requisites:** NONE. Not even Git.

**Implementation:**
1. **Bootstrap script** (`bootstrap.sh`):
   - Installs Nix (if needed)
   - Creates ephemeral shell with Git + Gum
   - Clones repo and runs setup

2. **Ephemeral shell** (via `nix shell`):
   - Temporary environment with `git`, `gum`
   - User selects clone path and profile
   - Setup runs in that shell, then exits

3. **No circular dependencies:**
   - Bootstrap doesn't require Mise
   - Mise doesn't require Flakes
   - Each tool is optional

---

## The Stack (Why These Tools?)

### ❄️ Nix Flakes (OS Manager)

**Role:** System packages, drivers, daemon configuration.

**Why Nix?**
- Declarative: Define desired state, Nix achieves it
- Reproducible: `flake.lock` ensures exact versions
- Immutable: System state is predictable
- Multi-platform: Darwin, NixOS, WSL all supported

**Alternatives rejected:**
- ~~Ansible~~ Imperative, hard to version-control reproducibly
- ~~Homebrew Bundle~~ Weak for system-level config, no NixOS support
- ~~Pulumi~~ Overkill for personal infra

---

### 🔧 Mise (Task Runner + Tools Installer)

**Role:**
1. Install development tools (Node, Go, Python)
2. Define and run tasks (bootstrap, ui, switch, lint)

**Why Mise?**
- Simpler than Make (with environment isolation)
- Better than Just (supports tools installation)
- Language-agnostic
- `mise run` = runs task with implicit env

**vs Alternatives:**
- ~~Makefile~~ Archaïque, fragile
- ~~Just~~ No built-in tools, requires external install
- ~~Task~~ Good but Mise is cleaner for this use case

---

### 📂 GNU Stow (Dotfile Manager)

**Role:** Symlink dotfiles from `stow/` to `$HOME`.

**Why Stow?**
- Manages groups of symlinks atomically
- Profiles: `stow -S stow/common` installs common, `stow -S stow/work` installs work-specific
- Reverses cleanly: `stow -D` removes symlinks
- Compatible with Home-Manager (we use both)

**Separation from Home-Manager:**
- Home-Manager = **Immutable** Nix-managed configs (rebuilt on `switch`)
- Stow = **Mutable** dotfiles (editable in-place)
- They don't conflict; they complement each other

**Example Flow:**
```
flake.nix (Nix) ──> System packages, daemons
Home-Manager (Nix) ──> ~/.gitconfig (read-only from Nix)
Stow (Bash) ──> ~/.zshrc (editable)
```

---

### 📄 Fnox (Secret Management)

**Role:** Inject secrets from Keychain/Pass into environment at runtime.

**Why Fnox?**
- Minimal overhead
- Pluggable backends (Keychain, Pass, Vault)
- Integrates with SSH (Secretive compatibility)
- Never persists secrets to disk

**vs Alternatives:**
- ~~SOPS~~ Secrets stored in Git (even if encrypted)
- ~~Agenix~~ Same issue; too heavy for personal setup
- ~~Vault~~ Overkill; requires server

---

### 🔍 Hk (Git Hooks)

**Role:** Pre-commit linting (Nix format, markdown spell-check).

**Why Hk?**
- Written in Rust/Pkl (fast)
- Minimal dependencies
- Runs before commit

**vs Alternatives:**
- ~~Pre-commit~~ Heavy Python overhead
- ~~Husky~~ JavaScript-only

---

### 🧹 Gum (Interactive Scripts)

**Role:** Wizards for selecting profiles, adding apps, etc.

**Why Gum?**
- Minimal, composable CLI widgets
- Makes infrastructure setup user-friendly
- No dependencies (single binary)

---

### 🔐 Secretive (SSH Key Management)

**Role:** Secure Enclave storage of SSH private keys (hardware-backed).

**Why Secretive?**
- Keys never on disk
- TouchID/Face ID support
- Immune to disk theft
- Works seamlessly with Fnox

**Alternative rejected:**
- ~~~/.ssh/id_ed25519~~ Exposed on disk, vulnerable to malware

---

## Directory Structure Logic

```
nix-dotfiles/
├── flake.nix              # Nix Flakes (source of truth for system state)
├── mise.toml              # Task orchestration
├── bootstrap.sh           # One-liner entry point
│
├── modules/               # Reusable Nix components (like npm packages)
│   ├── common/            # Zsh, Starship, fonts (all machines)
│   ├── darwin/            # macOS-specific (Dock, Finder, TouchID)
│   ├── linux/             # Linux-specific (systemd services)
│   └── wsl/               # Windows WSL interop
│
├── hosts/                 # **MACHINES** (Hardware configurations)
│   ├── pro/macbook-pro/   # 🍎 Specific M3 MacBook
│   ├── pro/nixos-vps/     # 🐧 Specific VPS
│   └── perso/gaming-rig/  # 🪟 Specific Gaming PC
│
├── users/                 # **PEOPLE** (User environments)
│   ├── nnosal/            # Main user config (portable across machines)
│   └── guest/             # Limited guest user
│
├── stow/                  # **DOTFILES** (Live-editable)
│   ├── common/            # Applied to all contexts
│   ├── work/              # Work-only secrets, configs
│   └── personal/          # Personal hobbies, games
│
└── docs/                  # Documentation
```

### **Machines vs People (The Key Insight)**

**Machines (hosts/):**
- M3 MacBook Pro M3 is HERE in hosts/pro/macbook-pro
- Gaming rig is HERE in hosts/perso/gaming-rig
- VPS is HERE in hosts/pro/nixos-vps

**People (users/):**
- Me (nnosal) can log into any machine
- My config is portable
- `nnosal` config applies to all hosts I own

**Assembly:**
```nix
# In hosts/pro/macbook-pro/default.nix:
home-manager.users.nnosal = {
  imports = [ ../../../users/nnosal/default.nix ];
};
```

This says: "On this macbook-pro machine, apply the nnosal user config."

---

## Data Flow on `nh os switch`

1. **Entry:** User runs `nh os switch` on MacBook
2. **Flake Eval:** Nix reads `flake.nix`, detects hostname (`macbook-pro`)
3. **Host Load:** `hosts/pro/macbook-pro/default.nix` is evaluated
4. **Module Composition:** Modules are merged (common + darwin)
5. **Home-Manager:** User config `users/nnosal/` is loaded
6. **Build:** Nix builds system closure
7. **Stow Apply:** `mise run bootstrap` calls `stow -S` for profiles
8. **Activation:** New system state is activated (may require reboot on macOS)
9. **Secrets:** `fnox activate` in `.zshrc` loads AWS_KEY, etc.

---

## Security Model

### Threats Mitigated

1. **Disk Theft:** SSH keys in Secure Enclave (not on disk)
2. **Malware Access:** Secrets in Keychain, not env vars persisted
3. **Repository Compromise:** No secrets in Git, only public configs
4. **Unauthorized Sudo:** TouchID required (macOS)
5. **Config Drift:** Nix immutability prevents unauthorized changes

### Assumptions

- **Keychain/Pass master password is strong**
- **Secure Enclave is not compromised** (Apple hardware security)
- **Git repository is public** (no secrets)
- **Nix daemon runs as root** (necessary for system config)

---

## Extensibility

### Adding a New Machine

```bash
# Create new host:
mkdir -p hosts/pro/new-machine
cat > hosts/pro/new-machine/default.nix << 'EOF'
{ pkgs, ... }: {
  imports = [
    ../../../modules/common/shell.nix
    ../../../modules/darwin
  ];
  networking.hostName = "new-machine";
  # ...
}
EOF
```

### Adding a New User

```bash
mkdir -p users/alice
cat > users/alice/default.nix << 'EOF'
{ pkgs, ... }: {
  imports = [ ../../modules/common/shell.nix ];
  home.username = "alice";
  home.packages = with pkgs; [ /* her tools */ ];
}
EOF
```

### Adding a New Profile

```bash
mkdir -p stow/research
# Put research-specific dotfiles here
stow -S stow/research  # Apply when needed
```

---

## Why This Design Wins

✅ **Reproducible** - Flakes + Nix = exact versions
✅ **Scalable** - Grows from 1 machine to 10 without complexity
✅ **Maintainable** - Clear separation: system vs user vs dotfiles
✅ **Flexible** - Stow profiles let you mix and match
✅ **Secure** - No secrets in repo, hardware-backed keys
✅ **Fast to Setup** - One-liner bootstrap
✅ **Fast to Iterate** - Live editing without rebuilds

This is the **Ultimate Personal DevOps Setup** 🚀
