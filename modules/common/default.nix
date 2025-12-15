{ pkgs, lib, config, ... }:
{
  imports = [
    ./shell.nix
    ./style.nix
    ./packages.nix
  ];
}
