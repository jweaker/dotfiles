[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme ]] ||
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' min-delay 0.01 
zstyle ':autocomplete:history-search:*' list-lines 25
zstyle ':autocomplete:*' list-lines 25 

export EDITOR=code
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_AVD_HOME=$HOME/.android/avd
export BUN_INSTALL="$HOME/.bun" 
export PATH=$PATH:$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:/usr/local/go/bin:$BUN_INSTALL/bin:$HOME/.local/bin


export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
git
history
dirhistory
jsontools
sudo
zsh-autosuggestions
zsh-autocomplete
web-search
dirhistory
copypath
copyfile
copybuffer
zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

DISTRONAME=$(uname -n)
if [[ "$DISTRONAME" = "fedora" ]]
then
	alias i="sudo dnf install "
	alias upg="sudo dnf upgrade "
else
	alias i="sudo apt install "
	alias upg="sudo apt upgrade "
	alias upd="sudo apt update "
fi

if (( $+commands[nala] ))
then
	alias apt=\\nala apts=\\apt
fi

if (( $+commands[lvim] ))
then
	alias vim="lvim "
fi

bindkey '^H' backward-kill-word

