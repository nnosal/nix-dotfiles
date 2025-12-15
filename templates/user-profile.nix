{ pkgs, ... }: {
  imports = [
    ../../modules/common/shell.nix
    ../../modules/common/style.nix
    ../../modules/common/packages.nix
  ];

  # Identité Git
  programs.git = {
    enable = true;
    userName = "%FULLNAME%";
    userEmail = "%EMAIL%";
  };

  home.stateVersion = "24.05";
}
