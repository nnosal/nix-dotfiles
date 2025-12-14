# 📄 Common Zsh Configuration (via Stow)
# This file is symlinked by GNU Stow from stow/common
# It can be edited directly without Nix rebuild (live editing)

# === ALIASES ===
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# === GIT ALIASES ===
alias ga='git add'
alias gst='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# === NAVIGATION ===
alias notes='cd $HOME/notes && code .'
alias dotfiles='cd $HOME/dotfiles'
alias projects='cd $HOME/projects'

# === DOCKER ===
alias d='docker'
alias dc='docker-compose'

# === DEVELOPMENT ===
alias v='nvim'
alias t='tmux'

echo "👋 Zsh ready (Stow-managed)"
