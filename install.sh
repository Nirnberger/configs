#!/usr/bin/env bash
# Bootstrap a new Mac after this repo is checked out into ~/.config (see README.md).
# Safe to re-run.
set -euo pipefail

CONFIG_DIR="$HOME/.config"

# Xcode command line tools (git, C compiler for treesitter parsers)
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Re-run ./install.sh once the command line tools finished installing."
  exit 1
fi

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file "$CONFIG_DIR/Brewfile"

# zsh: ~/.zshrc -> repo copy (existing file is backed up)
if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi
ln -sfn "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"

# tmux plugins
if [ ! -d "$CONFIG_DIR/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$CONFIG_DIR/tmux/plugins/tpm"
fi
"$CONFIG_DIR/tmux/plugins/tpm/bin/install_plugins"

# nvim plugins at the versions pinned in lazy-lock.json
nvim --headless "+Lazy! restore" +qa

echo "Done. Open nvim once and let Mason/treesitter finish installing (:Mason, :checkhealth)."
