#!/bin/zsh

export ZSH="$HOME/.zsh"

if ! foobar_loc="$(type -p "starship")" || [[ -z $foobar_loc ]]; then
    curl -sS https://starship.rs/install.sh | sh
fi

[[ -f $ZSH/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] ||
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH/plugins/zsh-autocomplete


[[ -f $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] ||
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/plugins/zsh-syntax-highlighting

[[ -f $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] ||
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/plugins/zsh-autosuggestions

[[ -f $ZSH/plugins/zsh-completions/zsh-completions.plugin.zsh ]] ||
git clone https://github.com/zsh-users/zsh-completions $ZSH/plugins/zsh-completions

if [[ ! -f $ZSH/plugins/omz/sudo.plugin.zsh ]]; then
    mkdir $ZSH/plugins/omz/
    curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o  $ZSH/plugins/omz/sudo.plugin.zsh
fi


if [[ $(uname) != "Darwin" ]]; then
    if [[ -z "$(fc-list 'JetBrainsMono Nerd Font')" ]]; then
        mkdir -p ~/.local/
        mkdir -p ~/.local/share/
        mkdir -p ~/.local/share/fonts/
        mkdir -p ~/.local/share/fonts/jetbrains/
        cd ~/.local/share/fonts/jetbrains/
        curl -OL 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.tar.xz'
        xz -d JetBrainsMono.tar.xz
        tar -xf JetBrainsMono.tar
        rm JetBrainsMono.tar
        tar -xf JetBrainsMono.tar
        rm JetBrainsMono.tar
        cd
    fi
fi


source $ZSH/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source $ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZSH/plugins/omz/sudo.plugin.zsh

fpath+=($ZSH/plugins/zsh-completions/src $fpath)

# Completions
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)
autoload -U compinit && compinit

# Colors
autoload -Uz colors && colors

if (( $+commands[nvim] ))
then
    export EDITOR=nvim
elif (( $+commands[vim] ))
then
    export EDITOR=vim
elif (( $+commands[code] ))
then
    export EDITOR=code
else
    export EDITOR=vi
fi

if [[ $(uname) == "Darwin" ]]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
    export ANDROID_HOME=$HOME/Library/Android/Sdk
    export ANDROID_SDK_ROOT=$HOME/Library/Android/Sdk
else
    export ANDROID_SDK_ROOT=$HOME/Android/Sdk
    export ANDROID_HOME=$HOME/Android/Sdk
fi




if [[ $(uname) == "Darwin" ]]; then
    export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Turso
export PATH="$HOME/.turso:$PATH"

export ANDROID_AVD_HOME=$HOME/.android/avd
export PATH="$PATH:/usr/local/bin:$HOME/.cargo/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:/$ANDROID_SDK_ROOT/tools:/usr/local/go/bin:$HOME/.local/bin"
export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin"
export HISTFILE=~/.zsh_history
export HISTSIZE=10000000
export SAVEHIST=$HISTSIZE



if (( $+commands[brave] ))
then
    export BROWSER=brave
elif (( $+commands[firefox] ))
then
    export BROWSER=firefox
fi

if (( $+commands[pacman] ))
then
    alias i="sudo pacman -Syu "
    alias upg="sudo pacman -Syu "
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

if (( $+commands[eza] ))
then
    alias ls="eza --icons "
elif (( $+commands[exa] ))
then
    alias ls="exa --icons "
fi

if (( $+commands[nala] ))
then
    alias apt=\\nala apts=\\apt
fi

if (( $+commands[nvim] ))
then
    alias vim="nvim "
    if (( $+commands[neovide] ))
    then
        alias vimg="neovide --multigrid"
    fi
fi

WORDCHARS=${WORDCHARS/\/}

bindkey -v
bindkey '^H' backward-kill-word
bindkey "^?" backward-delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

eval "$(starship init zsh)"
