HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
export HISTFILE HISTSIZE SAVEHIST

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt combining_chars
setopt interactive_comments

autoload -Uz colors compinit
colors
zmodload zsh/complist
_comp_options+=(globdots)
compinit -C -D

if (( $+commands[eza] )); then
  alias ls='eza --icons=auto'
elif (( $+commands[exa] )); then
  alias ls='exa --icons'
fi

if (( $+commands[pacman] )); then
  alias i='sudo pacman -S'
  alias upd='sudo pacman -Sy'
  alias upg='sudo pacman -Syu'
elif (( $+commands[nala] )); then
  alias i='sudo nala install'
  alias upd='sudo nala update'
  alias upg='sudo nala upgrade'
elif (( $+commands[apt] )); then
  alias i='sudo apt install'
  alias upd='sudo apt update'
  alias upg='sudo apt upgrade'
elif (( $+commands[dnf] )); then
  alias i='sudo dnf install'
  alias upg='sudo dnf upgrade'
fi

(( $+commands[nvim] )) && alias vim='nvim'
alias vimsudo='sudo visudo -f'

work() {
  tmux new-session -A -s "${1:-work}"
}

WORDCHARS=${WORDCHARS//\//}
bindkey -v
bindkey '^H' backward-kill-word
bindkey '^?' backward-delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
fi
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
