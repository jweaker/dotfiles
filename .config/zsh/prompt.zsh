typeset -g ZSH="${ZSH:-$HOME/.zsh}"

if [[ -t 0 && -t 1 && -f "$ZSH/P10K" && -r "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
elif (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
