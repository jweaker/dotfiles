#!/usr/bin/env zsh

[[ -o interactive ]] || return

# Use one managed plugin root on every host. Do not inherit an application's
# stale ZSH value, which can otherwise select a different prompt/plugin tree.
export ZSH="$HOME/.zsh"

# Zsh renders prompts on stderr. Some macOS terminal launchers keep stderr on
# the PTY while redirecting stdout, so stdout is not a reliable prompt test.
if [[ -t 2 && -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -r "$HOME/.config/shell/env.sh" ]] && source "$HOME/.config/shell/env.sh"
[[ -r "$HOME/.config/zsh/common.zsh" ]] && source "$HOME/.config/zsh/common.zsh"

case "$OSTYPE" in
  darwin*) [[ -r "$HOME/.config/zsh/macos.zsh" ]] && source "$HOME/.config/zsh/macos.zsh" ;;
  linux*)  [[ -r "$HOME/.config/zsh/linux.zsh" ]] && source "$HOME/.config/zsh/linux.zsh" ;;
esac

[[ -r "$HOME/.config/zsh/prompt.zsh" ]] && source "$HOME/.config/zsh/prompt.zsh"
[[ -r "$HOME/.config/zsh/plugins.zsh" ]] && source "$HOME/.config/zsh/plugins.zsh"
[[ -r "$HOME/.zsh_private" ]] && source "$HOME/.zsh_private"
[[ -r "$HOME/.local_secrets" ]] && source "$HOME/.local_secrets"
