{ pkgs, lib, config, ... }:
{
  imports = [
    ./security.nix
  ];

  # macOS System Defaults
  system.primaryUser = "admin";
  system.defaults = {
    dock.autohide = false;
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
