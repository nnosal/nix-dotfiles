{ pkgs, lib, config, ... }:
{
  # WSL Interop
  # Install wslview to open links in Windows browser
  home.packages = with pkgs; [
    wslu
  ];

  # Alias 'open' to 'wslview' for macOS-like experience
  programs.zsh.shellAliases = {
    open = "wslview";
    xdg-open = "wslview";
  };

  # Ensure we don't try to manage hardware config in WSL (handled by Hyper-V/Windows)
}
