{ pkgs, lib, config, ... }:
{
  imports = [
    ../../../modules/linux
    ./hardware-configuration.nix  # Import hardware config for bootloader and filesystems
  ];

  networking.hostName = "contabo1";

  users.users.nnosal = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  home-manager.users.nnosal = import ../../../users/nnosal/default.nix;

  system.stateVersion = "24.05";
}
