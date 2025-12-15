{
  description = "Ultimate Dotfiles";

  inputs = {
    # Annexe I: Fixed versions for stability
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";

    # Tools
    hk.url = "github:jdx/hk";
    fnox.url = "github:jdx/fnox";

    # Hardware optimizations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      lib = import ./lib { inherit inputs; };
    in {
      # Entry point for macOS machines
      darwinConfigurations."macbook-pro" = lib.mkSystem {
        system = "aarch64-darwin";
        modules = [ ./hosts/pro/macbook-pro/default.nix ];
      };

      # Entry point for Linux Servers (NixOS)
      nixosConfigurations."contabo1" = lib.mkSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/infra/contabo1/default.nix ];
      };

      # Entry point for WSL (Home Manager standalone mostly, or NixOS-WSL if used full distro)
      # Assuming Home Manager standalone for WSL based on "Partie 4: WSL géré par Home-Manager"
      # But usually we expose it via homeConfigurations if not using NixOS
      homeConfigurations."wsl" = lib.mkHome {
        system = "x86_64-linux";
        modules = [ ./hosts/perso/gaming-rig/wsl.nix ];
      };
    };
}
