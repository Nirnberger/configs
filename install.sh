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

# nvim plugins at the versions pinned in lazy-lock.json, then every Mason package (mason.lua)
nvim --headless "+Lazy! restore" +qa
echo "Installing language servers, formatters and debuggers (takes a few minutes)..."
nvim --headless "+MasonToolsInstallSync" +qa

# Dev boxes (tmux prefix D): ~/bin/dev comes from the home server. Needs Tailscale and an
# ssh key the server accepts; without them this is skipped and prefix D says what's missing.
# DEV_HOST lives in ~/.zshenv, which bash doesn't read (same lookup as tmux/scripts/dev-boxes.sh)
dev_host="${DEV_HOST:-$(zsh -c 'print -r -- $DEV_HOST' 2>/dev/null)}"
dev_host="${dev_host:-homeserver}"
if [ -x "$HOME/bin/dev" ]; then
  echo "~/bin/dev already there (update: ssh $dev_host cat code/infra/claude-dev/mac/dev > ~/bin/dev)"
elif ssh -o BatchMode=yes -o ConnectTimeout=5 "$dev_host" cat code/infra/claude-dev/mac/dev >"$HOME/.dev.tmp" 2>/dev/null \
  && [ -s "$HOME/.dev.tmp" ]; then
  mkdir -p "$HOME/bin"
  mv "$HOME/.dev.tmp" "$HOME/bin/dev"
  chmod +x "$HOME/bin/dev"
  echo "Installed ~/bin/dev from $dev_host."
else
  rm -f "$HOME/.dev.tmp"
  echo "Skipped ~/bin/dev: $dev_host not reachable over ssh (Tailscale on? ssh key added? DEV_HOST in ~/.zshenv?)."
  echo "  Re-run ./install.sh afterwards."
fi

echo "Done. Treesitter compiles its parsers the first time you open a file in nvim."
