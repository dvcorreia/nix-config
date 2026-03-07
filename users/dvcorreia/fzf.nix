{ config, ... }:

{
  programs.fzf = {
    enable = true;
    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
    tmux.enableShellIntegration = config.programs.tmux.enable;
  };
}
