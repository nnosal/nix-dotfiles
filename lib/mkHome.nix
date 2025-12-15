{ inputs }:

{ system, modules, specialArgs ? {} }:

let
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit inputs; } // specialArgs;
  modules = modules ++ [
    inputs.stylix.homeManagerModules.stylix
    {
      # Standard Home Manager config
      programs.home-manager.enable = true;
    }
  ];
}
