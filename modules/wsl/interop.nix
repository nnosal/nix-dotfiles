{ pkgs, ... }: {

  # 1. Utilitaires WSL (wslview, wslact)
  home.packages = [ pkgs.wslu ];

  # 2. Variables d'environnement critiques
  home.sessionVariables = {
    # Ouvre les liens (xdg-open) avec le navigateur par défaut de Windows
    BROWSER = "wslview";
    # Utilise l'affichage XServer (si installé sur Windows, optionnel)
    DISPLAY = ":0";
  };

  # 3. Alias pratiques
  programs.zsh.shellAliases = {
    # Ouvre l'explorateur Windows dans le dossier courant
    explorer = "explorer.exe .";
    # Copie dans le presse-papier Windows (via clip.exe)
    clip = "clip.exe";
    # Open standard alias
    open = "wslview";
    xdg-open = "wslview";
  };
}
