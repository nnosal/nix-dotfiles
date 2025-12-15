{ pkgs, lib, ... }:
{
  # Stub hardware config for CI/Verification
  # This allows us to build the system derivation without real hardware.

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/sda";
}
