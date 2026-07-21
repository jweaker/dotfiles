#!/usr/bin/env zsh

[[ -o interactive ]] || return

# Use one managed plugin root on every host. Do not inherit an application's
# stale ZSH value, which can otherwise select a different prompt/plugin tree.
export ZSH="$HOME/.zsh"

[[ -r "$HOME/.config/shell/env.sh" ]] && source "$HOME/.config/shell/env.sh"
[[ -r "$HOME/.config/zsh/common.zsh" ]] && source "$HOME/.config/zsh/common.zsh"

case "$OSTYPE" in
  darwin*) [[ -r "$HOME/.config/zsh/macos.zsh" ]] && source "$HOME/.config/zsh/macos.zsh" ;;
  linux*)  [[ -r "$HOME/.config/zsh/linux.zsh" ]] && source "$HOME/.config/zsh/linux.zsh" ;;
esac

[[ -r "$HOME/.config/zsh/plugins.zsh" ]] && source "$HOME/.config/zsh/plugins.zsh"
[[ -r "$HOME/.zsh_private" ]] && source "$HOME/.zsh_private"
[[ -r "$HOME/.local_secrets" ]] && source "$HOME/.local_secrets"

# Initialize the prompt last so plugins and private extensions cannot replace
# it during startup.
[[ -r "$HOME/.config/zsh/prompt.zsh" ]] && source "$HOME/.config/zsh/prompt.zsh"
