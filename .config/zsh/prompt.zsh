typeset -g ZSH="${ZSH:-$HOME/.zsh}"

# $TTY describes the controlling terminal and stays stable when launchers or
# parent shells temporarily redirect individual file descriptors.
if [[ -n "$TTY" && -f "$ZSH/P10K" && -r "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
