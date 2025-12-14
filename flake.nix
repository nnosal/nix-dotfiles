{
  description = "🔧 Dotfiles Universels Nix + Mise + Stow - macOS, Linux, Windows(WSL)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, darwin, home-manager, stylix, flake-utils }:
    let
      # Architecture supportées
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
      
      # Fonction helper pour créer une config NixOS
      mkNixosSystem = { system, hostname, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            { networking.hostName = hostname; }
            { nix.settings.experimental-features = [ "nix-command" "flakes" ]; }
          ] ++ modules;
        };

      # Fonction helper pour créer une config Darwin (macOS)
      mkDarwinSystem = { system, hostname, modules }:
        darwin.lib.darwinSystem {
          inherit system modules;
          specialArgs = { inherit self; };
        };

      # Fonction helper pour Home Manager Standalone
      mkHomeConfiguration = { system, username, modules }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          extraSpecialArgs = { inherit self; };
          modules = [
            stylix.homeManagerModules.stylix
          ] ++ modules;
        };

    in
    {
      # ============ HOSTS ============
      darwinConfigurations = {
        # 🍎 macOS Pro Workstation
        "macbook-pro" = mkDarwinSystem {
          system = "aarch64-darwin";
          hostname = "macbook-pro";
          modules = [ 
            ./hosts/pro/macbook-pro/default.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };

      nixosConfigurations = {
        # 🐧 Linux VPS
        "nixos-vps" = mkNixosSystem {
          system = "x86_64-linux";
          hostname = "nixos-vps";
          modules = [ 
            ./hosts/pro/nixos-vps/hardware-configuration.nix
            ./hosts/pro/nixos-vps/default.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # ============ HOME CONFIGS (Standalone - WSL/Headless) ============
      homeConfigurations = {
        # 🪟 Windows WSL Ubuntu
        "dt@gaming-rig" = mkHomeConfiguration {
          system = "x86_64-linux";
          username = "dt";
          modules = [ ./hosts/perso/gaming-rig/wsl.nix ];
        };

        # 🐧 Utilisateur standard sur une machine autre
        "nnosal@linux-desktop" = mkHomeConfiguration {
          system = "x86_64-linux";
          username = "nnosal";
          modules = [ ./users/nnosal/default.nix ];
        };
      };

      # ============ DEV ENVIRONMENT ============
      devShells = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              gum
              gnumake
              statix      # Linter Nix
              deadnix     # Détecte code mort
              nixfmt      # Formatter Nix
            ];
          };
        }
      );
    };
}
