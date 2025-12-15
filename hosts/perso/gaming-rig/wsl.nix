{ pkgs, lib, config, ... }:
{
  imports = [
    ../../../modules/wsl
    ../../../modules/common
  ];

  # In WSL, this file is imported by Home Manager standalone,
  # so we are in home-manager context.

  home.username = "nnosal";
  home.homeDirectory = "/home/nnosal";

  home.stateVersion = "24.05";
}
