typeset -g ZSH="${ZSH:-$HOME/.zsh}"

# Zsh writes prompts to stderr. Some macOS terminal launchers redirect stdout,
# so following the prompt stream keeps nested and fresh shells deterministic.
# Interactive shells without a terminal still use the lightweight fallback.
if [[ -t 2 && -f "$ZSH/P10K" && -r "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
