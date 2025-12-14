# 📄 Secrets & Credential Management

How to safely manage credentials in nix-dotfiles without storing secrets in Git.

## Philosophy

**Zero secrets in repository.** Even encrypted secrets are a liability.

Instead, we inject secrets at runtime from hardware-backed stores:
- **Keychain** (macOS) - Secure Enclave backed
- **Pass** (Linux) - Encrypted password manager
- **Secretive** (macOS) - SSH keys in Secure Enclave

---

## SSH Key Management

### macOS (Secretive + Secure Enclave)

**Install Secretive:**

It's included in the flake, but you can also get it manually:
```bash
brew install secretive
# Or from App Store
```

**Generate or Import Key:**
```bash
open -a Secretive
```

The app UI will guide you to:
1. Generate a new Ed25519 key (recommended)
2. OR import an existing key from `~/.ssh/id_ed25519`

**Verify Setup:**
```bash
# Check socket is available
ls -la ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# Test SSH
ssh-add -l  # Should list your key from Secretive

# Test git
git clone https://github.com/your-private-repo.git
```

**In Code:**

The `.zshrc` (via Home-Manager) already sets SSH_AUTH_SOCK:
```bash
if [[ -S $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh ]]; then
  export SSH_AUTH_SOCK=$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
fi
```

### Linux (SSH Agent)

**Generate Key (if not present):**
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

**Start SSH Agent:**
```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```

Or use `systemd --user` service:
```bash
sudo systemctl --user enable ssh-agent
sudo systemctl --user start ssh-agent
```

**Verify:**
```bash
ssh-add -l  # List keys
```

---

## Environment Variables (Fnox)

### What Fnox Does

**Fnox** injects environment variables from a secure backend:
- Reads from Keychain (macOS) or Pass (Linux)
- Populates ENV on shell init
- Variables never persisted to disk
- Cleared when shell exits

### macOS (Keychain)

**Add a Secret:**
```bash
# Method 1: Fnox CLI
fnox set AWS_ACCESS_KEY_ID "AKIA..."
fnox set AWS_SECRET_ACCESS_KEY "wJal..."

# Method 2: Keychain directly
security add-generic-password -a fnox -s AWS_ACCESS_KEY_ID -w "AKIA..."
security add-generic-password -a fnox -s AWS_SECRET_ACCESS_KEY -w "wJal..."
```

**List Secrets:**
```bash
fnox list

# Output:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
```

**Load in Shell:**
```bash
# Automatic (via .zshrc init)
eval "$(fnox activate zsh)"

# Or manually
export $(fnox list --export)
```

**Verify Loaded:**
```bash
echo $AWS_ACCESS_KEY_ID  # Should print your key
```

### Linux (Pass)

**Initialize Pass:**
```bash
# Generate GPG key (if not present)
gpg --gen-key

# Initialize pass
pass init "your-gpg-key-id"
```

**Add Secrets:**
```bash
# Via Fnox
fnox set AWS_ACCESS_KEY_ID "AKIA..."

# Or directly with pass
pass insert aws/access-key-id
# Type your key
```

**Configure Fnox Backend:**

Create `~/.config/fnox/config.toml`:
```toml
[backend]
type = "pass"  # or "keychain" on macOS
path = "fnox"  # Password store path
```

**Load in Shell:**
```bash
eval "$(fnox activate zsh)"
```

---

## Git Credentials

### SSH-based (Recommended)

Use SSH keys (Secretive/ssh-agent).

**No credentials file needed.**

```bash
# Test
git clone git@github.com:nnosal/private-repo.git
```

### HTTPS with Token

If you must use HTTPS:

**Store token in Keychain (macOS):**
```bash
fnox set GIT_TOKEN "ghp_xyz..."
```

**Use in Git Config:**

Create `~/.config/git/credentials` (NOT in repo):
```
https://username:token@github.com
```

Or use git-credential-store (transient):
```bash
git config --global credential.helper store
git clone https://github.com/nnosal/private-repo.git
# Enter credentials once, cached for session
```

---

## AWS Credentials

### Via Environment Variables (Fnox)

**Recommended for dev.**

```bash
fnox set AWS_ACCESS_KEY_ID "AKIA..."
fnox set AWS_SECRET_ACCESS_KEY "wJal..."
fnox set AWS_DEFAULT_REGION "eu-west-1"
```

Verify:
```bash
aws s3 ls  # Should work
```

### Via AWS Config (Multiple Profiles)

Create `~/.aws/config` (symlinked via Stow if shared):
```ini
[profile work]
region = eu-west-1
output = json

[profile personal]
region = eu-central-1
```

Create `~/.aws/credentials` (keep in Keychain, not file):
```
[work]
aws_access_key_id = AKIA...
aws_secret_access_key = wJal...

[personal]
aws_access_key_id = AKIA...
aws_secret_access_key = wJal...
```

Or load from Fnox:
```bash
eval "$(fnox activate zsh)"
aws s3 ls --profile work
```

---

## API Keys & Tokens

### General Pattern

**Never in .env files in repo.** Always use Fnox:

```bash
# GitHub
fnox set GITHUB_TOKEN "ghp_xyz..."

# OpenAI
fnox set OPENAI_API_KEY "sk-proj-xyz..."

# Custom API
fnox set MY_API_KEY "key_xyz..."
```

**In Application Code:**
```bash
eval "$(fnox activate zsh)"
echo $GITHUB_TOKEN  # Available
```

**In Nix Config:**

Do NOT hardcode:
```nix
# ❌ NEVER
services.myapp.apiKey = "sk-xyz...";  // LEAKED!

# ✅ Instead, use environment:
extraConfig = '''
  export API_KEY="$API_KEY"  # Injected by Fnox at shell init
''';
```

---

## Database Credentials

### Development

For local databases, use temporary passwords:
```bash
psql -U postgres -h localhost
# Set a dev password
ALTER USER dev WITH PASSWORD 'dev123';
```

Store in Fnox:
```bash
fnox set DB_PASSWORD "dev123"
```

### Production

**Never store in dotfiles.** Use:
- AWS Secrets Manager
- HashiCorp Vault
- GitHub Actions Secrets
- CI/CD pipeline environment variables

---

## Backup & Recovery

### Backup Secrets

**macOS (Keychain):**
```bash
# Export securely (not recommended, keep in Keychain)
# Instead: Use iCloud Keychain backup
```

**Linux (Pass):**
```bash
# Backup password store
tar -czf ~/pass-backup.tar.gz ~/.password-store/
# Keep encrypted and offline
```

### If You Lose Access

1. Regenerate SSH keys (Secretive or ssh-keygen)
2. Re-add public key to GitHub/GitLab
3. Re-add environment variables to Fnox
4. For production: Use cloud console to rotate credentials

---

## Security Checklist

✅ SSH keys in Secure Enclave (macOS) or ssh-agent (Linux)
✅ No secrets in Git (even `.gitignore`d files)
✅ Environment variables injected at runtime (Fnox)
✅ Keychain/Pass master password is strong
✅ Regular key rotation for API tokens
✅ Different credentials for work vs personal
✅ Production secrets managed externally (not in dotfiles)
✅ SSH config sanitized (no IP addresses or usernames in repo)

---

## Troubleshooting

### "fnox: command not found"

```bash
# Install via Nix flake
nh os switch

# Or manually
curl -fsSL https://mise.jdx.dev/install.sh | sh
mise use fnox
```

### "SSH_AUTH_SOCK not found"

**macOS:**
```bash
ls -la ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
# If missing, restart Secretive app
```

**Linux:**
```bash
ssh-add -l
# If error, start agent:
eval $(ssh-agent)
ssh-add ~/.ssh/id_ed25519
```

### "Keychain timeout"

**On macOS, if Keychain locks:**
```bash
security unlock-keychain  # May prompt for password
```

---

## References

- [Fnox GitHub](https://github.com/jdx/fnox)
- [Secretive GitHub](https://github.com/maxgoedjen/secretive)
- [Pass: The Standard Unix Password Manager](https://www.passwordstore.org/)
- [AWS CLI Credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

---

**Security is a process, not a destination.** Review regularly and rotate keys. 📄🔐
