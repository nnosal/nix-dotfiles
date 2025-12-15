{ pkgs, lib, config, ... }:
{
  # Install Secretive via Homebrew (it's a GUI app for TouchID SSH)
  homebrew.casks = [ "secretive" ];

  # Configure SSH to use Secretive's socket
  environment.variables = {
    SSH_AUTH_SOCK = "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
  };

  # Also ensure it's set in the shell for interactive sessions (though env var above should cover it)
  programs.zsh.initExtra = ''
    if [ -S "$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh" ]; then
      export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
    fi
  '';
}
