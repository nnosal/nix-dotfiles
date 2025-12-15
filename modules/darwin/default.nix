{ pkgs, lib, config, ... }:
{
  imports = [
    ./security.nix
  ];

  # macOS System Defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
  };

  # Homebrew
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    casks = [
      "ghostty"
      "arc"
      "raycast"
    ];
  };
}
