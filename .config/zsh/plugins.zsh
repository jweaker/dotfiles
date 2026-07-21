typeset -g ZSH="${ZSH:-$HOME/.zsh}"

typeset -a zsh_plugin_files=(
  "$ZSH/plugins/fzf-tab/fzf-tab.plugin.zsh"
  "$ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
  "$ZSH/plugins/omz/sudo.plugin.zsh"
)

for zsh_plugin_file in "${zsh_plugin_files[@]}"; do
  [[ -r "$zsh_plugin_file" ]] && source "$zsh_plugin_file"
done
unset zsh_plugin_file zsh_plugin_files

if [[ -d "$ZSH/plugins/zsh-completions/src" ]]; then
  fpath=("$ZSH/plugins/zsh-completions/src" $fpath)
fi

if [[ -r "$ZSH/plugins/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'command ls -la --color=always $realpath 2>/dev/null || command ls -la $realpath'
  zstyle ':fzf-tab:*' switch-group '<' '>'
fi

bindkey '^F' autosuggest-accept 2>/dev/null || true

# Syntax highlighting must be sourced last among plugins.
[[ -r "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$ZSH/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
