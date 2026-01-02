{ pkgs, lib, config, ... }:
{
  imports = [
    ../../../modules/darwin
  ];

  networking.hostName = "macbook-pro";

  # Admin user config
  users.users.nnosal = {
    name = "nnosal";
    home = "/Users/nnosal";
  };

  # Inject Home Manager config for nnosal
  home-manager.users.nnosal = import ../../../users/nnosal/default.nix;

  # Additional Casks for this specific host
  homebrew.casks = [
    "orbstack"
    "visual-studio-code"
  ];

  system.stateVersion = 5;
}
