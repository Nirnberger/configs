# brew bundle --file ~/.config/Brewfile
# For a full snapshot of this Mac instead: brew bundle dump --file ~/.config/Brewfile --force

# core
brew "git"
brew "neovim"
brew "tmux"

# nvim: telescope live_grep / find_files
brew "ripgrep"
brew "fd"
# nvim: mason (pyright, ts_ls, prettierd, graphql)
brew "node"
brew "python"
# nvim-treesitter (main branch) compiles parsers with the tree-sitter CLI
brew "tree-sitter-cli"
# Java: latest JDK runs jdtls (needs 25+), JDK 21 for projects (zshrc sets JAVA_HOME to it)
brew "openjdk"
brew "openjdk@21"
brew "maven"
brew "gradle"

# nvim: <leader>gg
brew "lazygit"

# AWS: CLI + per-shell profile switching (`assume <profile>`)
brew "awscli"
tap "common-fate/granted"
brew "granted"

# vimtex: PDF viewer. LaTeX itself is big, install when needed: brew install --cask mactex-no-gui
cask "skim"

# tmux: <prefix> f project switcher
brew "sesh"

# zsh
brew "fzf"
brew "zoxide"
brew "nvm"
brew "zsh-autosuggestions"

cask "font-jetbrains-mono-nerd-font"
cask "ghostty"

# Ghostty is the default terminal. Alacritty is optional and not allowed on the work Mac:
# its cask is disabled (fails Gatekeeper since 2026-09-01).
# Download the .dmg from https://github.com/alacritty/alacritty/releases, then:
#   xattr -dr com.apple.quarantine /Applications/Alacritty.app
