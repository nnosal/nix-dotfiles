# 🛧 Troubleshooting

Common issues and their solutions.

## Installation Issues

### "curl: command not found" on macOS

**Cause:** Xcode command-line tools not installed.

**Solution:**
```bash
xcode-select --install
# Then retry bootstrap
curl ... | bash
```

---

### "Nix installer failed"

**Cause:** Network issue, Nix dependencies missing, or macOS version too old.

**Solution:**
```bash
# Check macOS version (need 11+)
sw_vers

# Check network
ping github.com

# Manual install (Determinate Systems)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# If that fails, use official installer
https://nixos.org/download.html#nix-install-macos
```

---

### "Permission denied" on bootstrap

**Cause:** Script not executable.

**Solution:**
```bash
chmod +x bootstrap.sh
./bootstrap.sh

# Or pipe directly
bash bootstrap.sh
```

---

## Shell & Environment Issues

### "zsh: command not found: nix"

**Cause:** Nix not in PATH.

**Solution:**
```bash
# Source Nix environment
source ~/.nix-profile/etc/profile.d/nix.sh

# OR restart terminal for permanent fix
```

---

### Stow symlinks not created

**Cause:** Stow didn't run, or conflicting files exist.

**Solution:**
```bash
cd ~/dotfiles

# Check if .zshrc exists (non-symlink)
ls -la ~/.zshrc

# If it's a regular file, back it up
mv ~/.zshrc ~/.zshrc.backup

# Apply stow
stow -S stow/common

# Verify
ls -la ~/.zshrc  # Should show -> symlink
```

---

### "stow: CONFLICT: File exists"

**Cause:** Home directory file exists but not as symlink.

**Solution:**
```bash
# Check what's conflicting
ls -la ~/.zshrc

# If it's a regular file:
mv ~/.zshrc ~/.zshrc.backup

# If it's a symlink to wrong location:
rm ~/.zshrc

# Retry stow
stow -S stow/common
```

---

### "Zsh not loading aliases"

**Cause:** `.zshrc` not sourcing aliases file.

**Solution:**
```bash
# Check if .zshrc exists
cat ~/.zshrc | grep "aliases.zsh"

# If missing, check symlink
ls -la ~/.zshrc

# If it's symlinked to stow/common/.zshrc, ensure that file exists:
ls -la ~/dotfiles/stow/common/.zshrc

# Manually reload
source ~/.zshrc
```

---

## SSH & Git Issues

### "ssh: Permission denied (publickey)"

**Cause:** SSH key not available or SSH_AUTH_SOCK not set.

**Solution:**

**macOS (Secretive):**
```bash
# Check socket
ls -la ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# If missing, launch Secretive and add key
open -a Secretive

# Verify
ssh-add -l

# Test
ssh -vvv git@github.com  # Debug output
```

**Linux (ssh-agent):**
```bash
# Check agent running
ps aux | grep ssh-agent

# If not, start it
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519

# Verify
ssh-add -l
```

---

### "git: Permission denied"

**Same as SSH issue above.** Git uses SSH_AUTH_SOCK.

```bash
# Debug
GIT_SSH_COMMAND="ssh -v" git clone git@github.com:user/repo.git

# Check SSH_AUTH_SOCK
echo $SSH_AUTH_SOCK

# If empty, reload shell or manually export it
```

---

### "git config user.name" is empty

**Cause:** Home-Manager config not applied.

**Solution:**
```bash
# Check if set
git config user.name

# Rebuild
nixos-rebuild switch --flake .  # Linux
nh os switch --flake .           # macOS

# Or set manually
git config --global user.name "Nicolas Nosal"
git config --global user.email "nicolas.nosal@gmail.com"
```

---

## Nix & Flakes Issues

### "flake.lock is out of date"

**Cause:** Dependencies changed, need to update lock file.

**Solution:**
```bash
# Update flake inputs
nix flake update

# Or update specific input
nix flake update nixpkgs

# Then rebuild
nh os switch --flake .
```

---

### "error: file 'nixpkgs' was not found"

**Cause:** Flake lock file missing or corrupted.

**Solution:**
```bash
# Regenerate lock
cd ~/dotfiles
rm flake.lock
nix flake update

# Try again
nh os switch --flake .
```

---

### "home-manager: command not found"

**Cause:** Home-Manager not installed via Nix.

**Solution:**
```bash
# Install via flake
nix run github:nix-community/home-manager -- switch --flake .

# Or ensure flake.nix includes home-manager:
# (Check that it's in the flake inputs and outputs)
```

---

### "darwin-rebuild: command not found"

**Cause:** Not on macOS or nix-darwin not installed.

**Solution:**
```bash
# Check OS
uname -s  # Should print "Darwin"

# Use nix helper instead
nh os switch --flake .

# Or manually
nix run github:lnl7/nix-darwin -- switch --flake .
```

---

## Secrets & Keychain Issues

### "fnox: command not found"

**Cause:** Fnox not installed.

**Solution:**
```bash
# Install via Nix flake
nh os switch --flake .

# Or manually
curl -fsSL https://mise.jdx.dev/install.sh | sh
mise use fnox
```

---

### "SSH_AUTH_SOCK not found"

**Cause:** Secretive socket not available.

**Solution:**

**macOS:**
```bash
# Ensure Secretive is running
open -a Secretive

# Wait a few seconds
sleep 3

# Check socket
ls -la ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# Verify in shell
ssh-add -l
```

---

### "Keychain locked" (macOS)

**Cause:** Keychain security prompt.

**Solution:**
```bash
# Unlock keychain
security unlock-keychain

# Or allow fnox to use Keychain without prompt
security set-keychain-settings -lut 3600 ~/Library/Keychains/login.keychain-db
```

---

### "fnox list" returns nothing

**Cause:** No secrets added yet, or wrong backend.

**Solution:**
```bash
# Add a secret
fnox set TEST_VAR "test-value"

# List
fnox list

# Check backend config
cat ~/.config/fnox/config.toml

# macOS should use Keychain (default)
# Linux should use Pass
```

---

## Performance Issues

### "Switch is slow (5+ minutes)"

**Cause:** Large flake, many packages, or slow network.

**Solution:**
```bash
# Dry-run first (doesn't build)
nh os switch --show-trace  # Add --verbose for more detail

# Check what's building
nix flake show

# Reduce packages if possible (comment out unused ones)
```

---

### "Zsh startup is slow"

**Cause:** Too many plugins, aliases, or slow external commands.

**Solution:**
```bash
# Profile startup
time zsh -i -c exit

# Check .zshrc for slow commands
cat ~/.zshrc | grep -E "(eval|$(.*activate)|for)"

# Remove fnox if not using secrets
# Or use lazy loading for heavy tools
```

---

## macOS-Specific Issues

### "TouchID for sudo not working"

**Cause:** PAM config not enabled.

**Solution:**
```bash
# Enable via Nix (automatic)
nh os switch --flake .

# Or manually
sudo nano /etc/pam.d/sudo
# Add line: auth pam_reattach.so
```

---

### "Dock not configured"

**Cause:** Dock configuration not applied.

**Solution:**
```bash
# Edit dock config
vim ~/dotfiles/modules/darwin/default.nix

# Rebuild and reboot
nh os switch --flake .
reboot
```

---

## Linux-Specific Issues

### "systemd service not starting"

**Cause:** Service definition missing or syntax error.

**Solution:**
```bash
# Check service status
sudo systemctl status my-service

# Check logs
sudo journalctl -u my-service -n 50

# Fix config and rebuild
sudo nixos-rebuild switch --flake .
```

---

## WSL-Specific Issues

### "Nix WSL2 permission denied"

**Cause:** WSL2 doesn't have nix daemon.

**Solution:**
```bash
# Use nixpkgs WSL module
# (Covered in docs/ARCHITECTURE.md WSL section)

# Or use Home-Manager standalone
home-manager switch --flake .
```

---

## General Debugging Tips

### Enable verbose output

```bash
# Nix
nh os switch --show-trace --verbose

# Git
GIT_TRACE=1 git clone ...
GIT_SSH_COMMAND="ssh -v" git clone ...

# SSH
ssh -vvv git@github.com
```

### Check logs

```bash
# macOS system
log show --predicate 'process == "nix-daemon"' --last 5m

# Linux
journalctl -u nix-daemon -n 50
```

### Reset to clean state

```bash
# Remove all stow symlinks
cd ~/dotfiles
stow -D stow/common

# Remove Nix generation
nh clean all

# Start fresh
bootstrap.sh
```

---

## Still Stuck?

1. Check the **[ARCHITECTURE.md](ARCHITECTURE.md)** to understand the system
2. Review **[SETUP.md](SETUP.md)** for step-by-step instructions
3. Read **[SECRETS.md](SECRETS.md)** for credential issues
4. Search [Nix Discourse](https://discourse.nixos.org/)
5. Check [Nix-Darwin GitHub Issues](https://github.com/lnl7/nix-darwin/issues)
6. Open an issue on this repository

---

**Debugging is part of the journey.** Every error teaches you something about the system. 🛧❤️
