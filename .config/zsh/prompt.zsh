typeset -g ZSH="${ZSH:-$HOME/.zsh}"

# Use Powerlevel10k whenever output is a terminal. Embedded terminals can have
# non-TTY stdin, so testing stdout alone keeps the visible prompt deterministic.
# Non-TTY interactive shells use the lightweight prompt and avoid gitstatus's
# job-control requirement.
if [[ -t 1 && -f "$ZSH/P10K" && -r "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$ZSH/themes/powerlevel10k/powerlevel10k.zsh-theme"
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  PROMPT='%F{cyan}%n@%m%f:%F{blue}%~%f %# '
fi
