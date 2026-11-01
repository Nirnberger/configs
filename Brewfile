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
# vimtex: PDF viewer. LaTeX itself is big, install when needed: brew install --cask mactex-no-gui
cask "skim"

# zsh
brew "fzf"
brew "zoxide"
brew "nvm"
brew "zsh-autosuggestions"

cask "font-jetbrains-mono-nerd-font"

# The alacritty cask is disabled (fails Gatekeeper since 2026-09-01).
# Download the .dmg from https://github.com/alacritty/alacritty/releases, then:
#   xattr -dr com.apple.quarantine /Applications/Alacritty.app
