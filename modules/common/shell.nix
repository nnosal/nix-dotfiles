{ pkgs, lib, config, ... }:
{
  # Zsh Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Init Extra: Hook for Fnox (Zero-Trust) and Stow integration
    initExtra = ''
      # 1. Activer Fnox (Secrets en ENV)
      if command -v fnox > /dev/null; then
        eval "$(fnox activate zsh)"
      fi

      # 2. Lier le Socket SSH (Secretive ou Agent)
      if [[ -S $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh ]]; then
        export SSH_AUTH_SOCK=$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      elif [[ -S $XDG_RUNTIME_DIR/ssh-agent.socket ]]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
      fi

      # 3. Charger les Alias Stow
      # Si stow/common est lié, ceci chargera les fichiers
      [ -f ~/.config/zsh/aliases.zsh ] && source ~/.config/zsh/aliases.zsh
    '';
  };

  # Starship Prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
