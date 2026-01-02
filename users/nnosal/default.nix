{ pkgs, lib, config, ... }:
{
  imports = [
    ../../modules/common
  ];

  home.username = "nnosal";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/nnosal" else "/home/nnosal";

  home.stateVersion = "24.05"; # Match nixpkgs version roughly

  programs.git = {
    enable = true;
    settings.user.name = "nnosal";
    settings.user.email = "me@nnosal.com";
  };
}
