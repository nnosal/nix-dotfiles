# 🚀 Setup Guide

How to get from zero to a fully configured development environment.

## Prerequisites

- **macOS 11+** / **Linux** / **Windows 10+** (with WSL2)
- **Internet connection** (for Nix installation and package downloads)
- **~5-10 minutes** and patience

**That's it!** No need to pre-install Git, Nix, or anything else.

---

## Option 1: One-Liner Bootstrap (Recommended)

### macOS / Linux

```bash
curl https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.sh | bash
```

### Windows PowerShell

```powershell
irm https://raw.githubusercontent.com/nnosal/nix-dotfiles/main/bootstrap.ps1 | iex
```

The script will:

1. Detect your OS
2. Install Nix (if needed)
3. Create a temporary shell with Git + Gum
4. Ask where to clone the repository
5. Display an interactive setup wizard
6. Apply configurations
7. Print next steps

---

## Option 2: Manual Setup

If you prefer to see each step:

### 1. Install Nix

**macOS / Linux:**
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Windows (via WSL):**
```bash
# WSL bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --init none
```

Source Nix environment:
```bash
source ~/.nix-profile/etc/profile.d/nix.sh
```

### 2. Clone Repository

```bash
git clone https://github.com/nnosal/nix-dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Run Bootstrap Task

```bash
mise run bootstrap
```

Or directly:
```bash
bash bootstrap.sh
```

### 4. Choose Your Profile

When prompted, select:
- **common** - Always applied (Zsh, Git, Starship)
- **work** - Work-specific (AWS, SSH configs) *[optional]*
- **personal** - Personal hobbies, games *[optional]*

### 5. Apply Configuration

**macOS:**
```bash
nh os switch --flake .
```

**NixOS:**
```bash
sudo nixos-rebuild switch --flake .
```

**WSL (Home-Manager only):**
```bash
home-manager switch --flake .
```

---

## Post-Installation

### 1. Verify Installation

```bash
# Check Nix version
nix --version

# Check Zsh
zsh --version

# Test Git config
git config user.name

# Verify symlinks
ls -la ~/.zshrc    # Should be -> ~/dotfiles/stow/common/.zshrc
```

### 2. Load Shell

```bash
# Open new terminal or run:
exec zsh
```

You should see the Starship prompt and custom aliases working.

### 3. Setup Secrets (Important!)

Now is the time to add your secrets to the secure store.

**Add SSH Key (macOS):**
```bash
open -a Secretive  # Launch app
# Follow prompts to import or generate keys
```

**Add SSH Key (Linux):**
```bash
# SSH keys managed via ssh-agent or pass
ssh-add ~/.ssh/id_ed25519
```

**Add Environment Variables:**
```bash
# AWS credentials, API keys, etc.
fnox set AWS_ACCESS_KEY_ID "your-key"
fnox set AWS_SECRET_ACCESS_KEY "your-secret"

# Verify
fnox list
```

### 4. Test Git Configuration

```bash
# Clone a test repo
git clone https://github.com/nnosal/nix-dotfiles.git ~/test-clone
cd ~/test-clone

# Verify git author
git log --oneline -1

# Clean up
cd ~
rm -rf ~/test-clone
```

### 5. Optional: Enable Git Hooks

```bash
# If you want pre-commit linting
mise run lint  # Test the linter
```

---

## Troubleshooting

### "Command not found: nix"

**Solution:** Nix not in PATH. Source it manually:
```bash
source ~/.nix-profile/etc/profile.d/nix.sh
# Or restart terminal
```

### "Permission denied" on bootstrap

**Solution:** Make script executable:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### "Nix installation failed"

**Solution:** Use manual Nix installer:
```bash
https://github.com/DeterminateSystems/nix-installer  # Follow their guide
```

### SSH key not working

**macOS:** Verify Secretive is installed and keys are added:
```bash
ls -la ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
```

**Linux:** Check ssh-agent:
```bash
ssh-add -l  # List keys
ssh-add ~/.ssh/id_ed25519  # Add if missing
```

### Dotfiles not linked

**Solution:** Manually run Stow:
```bash
cd ~/dotfiles
stow -S stow/common
stow -S stow/work  # if applicable
```

### Home-Manager conflicting files

If HM and Stow conflict on the same file, resolution order:
1. Remove HM-managed version
2. Let Stow symlink take over
3. Or rename HM version (`~/.zshrc.hm-backup`)

---

## Next Steps

### 1. Explore the UI

```bash
mise run ui
```

Interactive menu for managing apps and config.

### 2. Edit Configuration

**System level (requires rebuild):**
```bash
vim ~/dotfiles/hosts/pro/macbook-pro/default.nix
mise run switch
```

**User level (mutable, no rebuild):**
```bash
vim ~/dotfiles/stow/common/.zshrc
source ~/.zshrc  # Instant
```

### 3. Add More Machines

Reuse the same flake on another computer:
```bash
curl ... | bash
```

The bootstrap will detect the new hostname and load appropriate config.

### 4. Customize for Your Needs

- Add preferred apps to Homebrew casks
- Add dev tools to Home-Manager packages
- Create new Stow profiles for specific contexts
- Modify Starship prompt colors

---

## Architecture Decision

The setup follows a **Host + User + Profiles** model:

- **Host:** The machine itself (MacBook, VPS, Gaming PC)
- **User:** The person using it (nnosal, guest, etc.)
- **Profiles:** Context groupings (work, personal, common)

This lets you:
✅ Share config across machines (portable users)
✅ Isolate contexts (work != personal)
✅ Scale to N machines without duplication

---

## Getting Help

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Understand the design
- **[SECRETS.md](SECRETS.md)** - Secure credential management
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues

---

**Welcome to your new dotfiles setup!** 🚀🎉
