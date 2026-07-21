if [[ -d "$HOME/Android/Sdk" ]]; then
  export ANDROID_HOME="$HOME/Android/Sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export ANDROID_NDK_HOME="$ANDROID_HOME/ndk"
  export ANDROID_AVD_HOME="$HOME/.android/avd"
fi

if [[ -x /var/lib/flatpak/exports/bin/app.zen_browser.zen ]]; then
  export BROWSER=/var/lib/flatpak/exports/bin/app.zen_browser.zen
fi

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Keep personal wrappers ahead of version-manager shims after mise rewrites
# PATH. This is used by the account-aware Codex launcher on remote hosts.
path=("$HOME/.local/bin" ${path:#$HOME/.local/bin})
export PATH
