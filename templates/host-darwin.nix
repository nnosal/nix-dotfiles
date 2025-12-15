{ pkgs, ... }: {
  imports = [
    ../../modules/darwin      # Capacités Mac
  ];

  # Spécifique Machine
  networking.hostName = "%HOSTNAME%";

  # Apps Système (installées dans /Applications)
  homebrew.casks = [
    # "visual-studio-code"
  ];

  # Import des Humains
  home-manager.users.nnosal = import ../../../users/nnosal/default.nix;

  system.stateVersion = 5;
}
