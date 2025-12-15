{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    ../../modules/linux
    # ../../modules/common # Common modules are imported via Home Manager user
  ];

  networking.hostName = "%HOSTNAME%";

  # Bootloader standard
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Import User Admin
  users.users.root.hashedPassword = "!"; # Désactivé (SSH Keys only)
  home-manager.users.nnosal = import ../../../users/nnosal/default.nix;

  system.stateVersion = "24.05";
}
