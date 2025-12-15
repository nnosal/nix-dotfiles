{ pkgs, lib, config, ... }:
{
  homebrew.casks = [
    # %% CASKS %%
    "ghostty"
    "arc"
    "raycast"
    "visual-studio-code"
    "docker"
    "slack"
  ];
}
