{ pkgs, lib, config, ... }:
{
  home.packages = with pkgs; [
    # %% PACKAGES %%
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
    nh

    # Editors
    neovim

    # Languages (Base)
    nodejs
    go
    rustc
    cargo
  ];
}
