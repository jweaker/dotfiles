# Shared POSIX login environment. Keep this file silent for SSH automation.
if [ -r "$HOME/.config/shell/env.sh" ]; then
  . "$HOME/.config/shell/env.sh"
fi
