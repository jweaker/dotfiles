typeset -g ZSH="${ZSH:-$HOME/.zsh}"

# Interactive shells always choose the same prompt.  The previous TTY check
# made embedded terminals fall through to Starship while normal PTYs loaded
# Powerlevel10k, which made new terminals appear to alternate themes.
if [[ -f "$ZSH/P10K" && -r "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
