{ pkgs, lib, config, ... }:
{
  # Linux specific configurations
  # e.g. systemd services, different packages

  services.openssh.enable = true;
  programs.zsh.enable = true;
}
