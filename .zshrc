if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=vim
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_AVD_HOME=$HOME/.android/avd
export BUN_INSTALL="$HOME/.bun" 
export PATH=$PATH:$HOME/bin:/usr/local/bin:$HOME/.cargo/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools:/usr/local/go/bin:$BUN_INSTALL/bin

[[ -f ~/Git/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/Git/zsh-autocomplete

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme ]] ||
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

[[ -f ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] ||
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


source ~/Git/zsh-autocomplete/zsh-autocomplete.plugin.zsh


export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
git
history
dirhistory
jsontools
sudo
zsh-autosuggestions
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
	alias apt=\\nala apts=\\apt
	alias i="sudo apt install "
	alias upg="sudo apt upgrade "
	alias upd="sudo apt update "
fi

if (( $+commands[lvim] ))
then
	alias vim="lvim "
fi

bindkey '^H' backward-kill-word
