{ pkgs, ... }: {
  imports = [
    ../../../modules/common/shell.nix
    ../../../modules/darwin
  ];

  # ========== CONFIGURATION SYSTÈME ==========
  networking.hostName = "macbook-pro";
  networking.computerName = "MacBook Pro";
  networking.localHostName = "macbook-pro";

  # 💤 System sleep/wake
  system.powerManagement.enable = true;

  # ========== HOMEBREW APPS ==========
  homebrew = {
    brews = [ ];
    casks = [
      "visual-studio-code"
      "docker"
      "slack"
      "discord"
      "google-chrome"
      "firefox"
      "vlc"
      "1password"
      "iterm2"
      "raycast"
      "rectangle"
    ];
  };

  # ========== USER CONFIGURATION ==========
  users.users.nnosal = {
    home = "/Users/nnosal";
    description = "Nicolas Nosal";
  };

  # ========== HOME-MANAGER ==========
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nnosal = { ... }: {
      imports = [ ../../../users/nnosal/default.nix ];
      
      # Context-specific overrides
      home.sessionVariables = {
        MACHINE_CONTEXT = "work";
        MACHINE_NAME = "macbook-pro";
      };

      # macOS-specific CLI tools
      home.packages = with pkgs; [
        nh                      # Nix helper (switch, clean, etc)
        darwin-rebuild          # Nix-Darwin builder
        fnox                    # Secret management
      ];
    };
  };
}
