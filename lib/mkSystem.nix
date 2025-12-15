{ inputs }:

{ system, modules, specialArgs ? {} }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  isDarwin = builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ];

  # Base modules common to all systems
  baseModules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.stylix.darwinModules.stylix
  ];

  linuxModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
  ];

  builder = if isDarwin
            then inputs.darwin.lib.darwinSystem
            else inputs.nixpkgs.lib.nixosSystem;

  extraModules = if isDarwin then baseModules else linuxModules;

in builder {
  inherit system;
  specialArgs = { inherit inputs; } // specialArgs;
  modules = extraModules ++ modules ++ [
    {
      # Configure Home Manager globally
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.backupFileExtension = "backup"; # Avoid conflict with existing files
    }
  ];
}
