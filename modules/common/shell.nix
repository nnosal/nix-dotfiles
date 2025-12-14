{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    history = {
      size = 10000;
      save = 10000;
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
    };

    # 📄 Alias et fonctions personnalisées
    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      l = "ls -CF";
      cd.. = "cd ..";
      grep = "grep --color=auto";
    };

    # 🟣 Initialisation : Fnox (Secrets), SSH, Stow
    initExtra = ''
      # 1. 📄 Activer Fnox (Secrets en ENV)
      if command -v fnox &> /dev/null; then
        eval "$(fnox activate zsh)"
      fi

      # 2. 🔐 SSH Auth Socket (Secretive ou Keychain)
      if [[ -S $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh ]]; then
        export SSH_AUTH_SOCK=$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      elif [[ -S $XDG_RUNTIME_DIR/ssh-agent.socket ]]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
      fi

      # 3. 📑 Charger les alias depuis Stow (si dispos)
      [ -f ~/.config/zsh/aliases.zsh ] && source ~/.config/zsh/aliases.zsh
      [ -f ~/.config/zsh/functions.zsh ] && source ~/.config/zsh/functions.zsh

      # 4. 🙋 Comportements optionnels
      setopt no_case_glob                  # Case-insensitive globbing
      setopt hist_ignore_space             # Don't save commands starting with space
      unsetopt beep                         # Désactiver le beep
    '';
  };

  # 🌟 Prompt uniforme (cross-platform)
  programs.starship = {
    enable = true;
    settings = {
      format = ''
        $directory$git_branch$git_status$nix_shell$line_break$character
      '';
      directory.truncation_length = 3;
      nix_shell.symbol = "🚟 ";
      git_branch.symbol = "🌲 ";
    };
  };

  # 🚄 Atuin - Fuzzy history search
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
}
