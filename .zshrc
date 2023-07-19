export ZSH="$HOME/.zsh"
export EDITOR=vim
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_AVD_HOME=$HOME/.android/avd
export PATH=$PATH:/usr/local/bin:$HOME/.cargo/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:/usr/local/go/bin:$HOME/.local/bin
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt hist_ignore_space

[[ -f ${ZSH}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH}/plugins/zsh-autocomplete

[[ -f ${ZSH}/themes/powerlevel10k/powerlevel10k.zsh-theme ]] ||
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH}/themes/powerlevel10k

[[ -f ${ZSH}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH}/plugins/zsh-syntax-highlighting

[[ -f ${ZSH}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH}/plugins/zsh-autosuggestions

[[ -f ${ZSH}/plugins/zsh-completions/zsh-completions.plugin.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-completions ${ZSH}/plugins/zsh-completions

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' rehash true  
zmodload zsh/complist
compinit

source ${ZSH}/themes/powerlevel10k/powerlevel10k.zsh-theme
source ${ZSH}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source ${ZSH}/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source ${ZSH}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

fpath+=(${ZSH}/plugins/zsh-completions/src $fpath)

zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' min-delay 0.01 
zstyle ':autocomplete:history-search:*' list-lines 25
zstyle ':autocomplete:*' list-lines 25 

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if (( $+commands[pacman] ))
then

	alias i="pacman -Syu "
	alias upg="pacman -Syu "
elif (( $+commands[apt] ))
then
	alias i="sudo apt install "
	alias upg="sudo apt upgrade "
	alias upd="sudo apt update "
elif (( $+commands[dnf] ))
then
	alias i="sudo dnf install "
	alias upg="sudo dnf upgrade "
fi

if (( $+commands[exa] ))
then
	alias ls="exa --icons "
fi

if (( $+commands[nala] ))
then
	alias apt=\\nala apts=\\apt
fi

if (( $+commands[lvim] ))
then
	alias vim="lvim "
elif (( $+commands[nvim] ))
then
	alias vim="nvim "
fi

WORDCHARS=${WORDCHARS/\/}

bindkey '^H' backward-kill-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
