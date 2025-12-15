{ pkgs, lib, config, ... }:
{
  home.packages = with pkgs; [
    # Core Tools
    git
    curl
    wget
    tree
    jq
    ripgrep
    fd
    bat
    fzf

    # Task Runner & UI
    mise
    gum

    # Editors
    neovim

    # Languages (Base)
    nodejs
    go
    rustc
    cargo
  ];
}
