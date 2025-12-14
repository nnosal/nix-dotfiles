{ pkgs, ... }: {
  imports = [ 
    ../../modules/common/shell.nix
  ];

  # ========== IDENTITY ==========
  home.username = "nnosal";
  home.homeDirectory = "/Users/nnosal";
  home.stateVersion = "24.05";

  # ========== GIT CONFIGURATION ==========
  programs.git = {
    enable = true;
    userName = "Nicolas Nosal";
    userEmail = "nicolas.nosal@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.default = "simple";
      core.editor = "code --wait";
      core.pager = "bat";
      diff.colorMoved = "default";
    };

    # SSH config management
    includes = [
      { path = "~/.config/git/profiles.conf"; }
    ];
  };

  # ========== DEV TOOLS ==========
  home.packages = with pkgs; [
    # Essential
    bat
    eza
    fzf
    ripgrep
    jq
    yq
    wget
    curl

    # Dev / DevOps
    git-lfs
    k9s
    lazygit
    nh                  # Nix helper
    statix              # Nix linter
    deadnix             # Nix dead code detector
    nixfmt              # Nix formatter
    nix-prefetch-git    # For flake inputs

    # Node.js (from mise in flake)
    # node
    # pnpm

    # Optional: Other tools
    # lazydocker
    # starship (configured above)
  ];

  # ========== EDITOR ==========
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-sleuth
    ];
  };

  # ========== SESSION VARIABLES ==========
  home.sessionVariables = {
    EDITOR = "vim";
    PAGER = "less";
    # Add more as needed
  };

  # ========== DOTFILES MANAGEMENT (Stow) ==========
  # Note: Stow is NOT managed by Home-Manager here.
  # It's installed separately and configured in flake.nix/mise.toml.
  # This separation allows live editing of configs without HM rebuilds.

  # ========== ZSH COMPLETION ==========
  programs.zsh.completionInit = '''
    fpath+=("${pkgs.nix-zsh-completions}/share/zsh/site-functions")
  ''';
}
