{ pkgs, lib, config, ... }:
{
  # Zsh Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Init Extra: Hook for Fnox (Zero-Trust)
    # This evaluates the secrets from Keychain into RAM at shell startup.
    initExtra = ''
      if command -v fnox > /dev/null; then
        eval "$(fnox activate zsh)"
      fi

      # Source local stow configs if they exist (handled by Stow, but we can ensure path)
      # export ZDOTDIR=$HOME/.config/zsh
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
