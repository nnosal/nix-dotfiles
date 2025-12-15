{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.modules.my-feature;
in
{
  options.modules.my-feature = {
    enable = mkEnableOption "Enable my-feature";
  };

  config = mkIf cfg.enable {
    # 1. Paquets
    home.packages = with pkgs; [ ];

    # 2. Configs
    programs.zsh.shellAliases = { };

    # 3. Variables d'env
    home.sessionVariables = { };
  };
}
