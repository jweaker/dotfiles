if [[ "$TERM_PROGRAM" == "iTerm.app" && -r "$HOME/.iterm2_shell_integration.zsh" ]]; then
  source "$HOME/.iterm2_shell_integration.zsh"
fi

if [[ -d "$HOME/Library/Android/Sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/Sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export ANDROID_NDK_HOME="$ANDROID_HOME/ndk"
  export ANDROID_AVD_HOME="$HOME/.android/avd"
fi

if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

if (( $+commands[jenv] )); then
  eval "$(jenv init - --no-rehash)"
fi
