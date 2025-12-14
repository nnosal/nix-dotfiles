{ pkgs, lib, ... }: {
  # 🍎 System configuration for macOS
  system.stateVersion = 5;

  # 🛡️ Sécurité : TouchID pour sudo
  security.pam.enableSudoTouchIdAuth = true;

  # 📑 Homebrew - Installation de casks et formulas
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Supprimer les vieilles versions
    brews = [
      "mas"                    # Mac App Store CLI
      "gnu-tar"               # Tar avec support long paths
      "coreutils"             # GNU utils
    ];
    casks = [
      "secretive"             # SSH keys in Secure Enclave
      "raycast"               # Spotlight replacement
      "rectangle"             # Window management
    ];
  };

  # 🖥️ Keyboard + Trackpad
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # 🎨 Appearance
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      minimize-to-application = true;
      orientation = "bottom";
      show-recents = false;
      show-process-indicators = true;
      tilesize = 48;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    NSGlobalDomain = {
      AppleFontSmoothing = 2;
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    ScreenCapture.location = "~/Downloads";
  };

  # 🔧 Nix daemon improvements
  nix.linux-builder.enable = false;  # Only if you're doing aarch64-linux builds from macOS
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
    cores = 0;  # Auto-detect
    max-jobs = "auto";
  };
}
